import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/episode_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/widgets/app_widgets.dart';
import 'download_controller.dart';
import '../../subscription/widgets/unlock_sheet.dart';
import '../../../core/utils/secure_screen.dart';

/// HLS sifat varianti (masalan 720p -> .../720p/video.m3u8).
class VideoQuality {
  final int height;
  final String url;

  const VideoQuality(this.height, this.url);

  String get label => '${height}p';

  /// Master playlist'dan `#EXT-X-STREAM-INF ... RESOLUTION=WxH` qatorlarini o'qiydi.
  static List<VideoQuality> parseMaster(String content, String masterUrl) {
    final base = masterUrl.substring(0, masterUrl.lastIndexOf('/') + 1);
    final lines = content.split('\n').map((l) => l.trim()).toList();
    final result = <VideoQuality>[];
    for (var i = 0; i < lines.length - 1; i++) {
      if (!lines[i].startsWith('#EXT-X-STREAM-INF')) continue;
      final res = RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(lines[i]);
      final uri = lines[i + 1];
      if (res == null || uri.isEmpty || uri.startsWith('#')) continue;
      result.add(VideoQuality(int.parse(res.group(1)!), uri.startsWith('http') ? uri : base + uri));
    }
    result.sort((a, b) => b.height.compareTo(a.height));
    return result;
  }
}

class PlayerController extends GetxController with WidgetsBindingObserver {
  final ApiProvider _apiProvider = ApiProvider();

  late final Player player;
  late final VideoController videoController;

  var isLoading = true.obs;
  var currentSeriesId = 0.obs;
  var seriesTitle = ''.obs;
  var episodes = <EpisodeModel>[].obs;
  var currentEpisode = Rxn<EpisodeModel>();
  var selectedSeason = Rxn<int>();

  // Tab index (0: Barcha qism, 1: Ko'rilganlar, 2: Yuklanganlar)
  var currentTabIndex = 0.obs;

  Timer? _progressTimer;

  List<int> get seasons =>
      (episodes.map((e) => e.seasonNumber ?? 1).toSet().toList()..sort());

  /// To'liq ekranga kirish: avval yo'nalishni, keyin tizim panellarini o'zgartiramiz —
  /// bir vaqtda qilinsa Android ikki marta qayta chizadi va o'tish "sakraydi".
  static Future<void> enterFullscreen() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// To'liq ekrandan chiqish: to'g'ridan-to'g'ri vertikalga (media_kit standarti yo'nalishni
  /// erkin qoldirardi va sahifa bir lahza "qaysi tomonga burilay" deb sakrab olardi).
  static Future<void> exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  /// "Barcha qism" tabidagi son — tanlangan fasldagi qismlar.
  int get visibleEpisodesCount => selectedSeason.value == null
      ? episodes.length
      : episodes.where((e) => (e.seasonNumber ?? 1) == selectedSeason.value).length;

  List<EpisodeModel> get visibleEpisodes {
    var list = episodes.toList();
    if (selectedSeason.value != null) {
      list = list.where((e) => (e.seasonNumber ?? 1) == selectedSeason.value).toList();
    }
    if (currentTabIndex.value == 1) {
      list = list.where((e) => (e.watchedSeconds ?? 0) > 0).toList();
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    player = Player();
    videoController = VideoController(player);
    // Video ko'rsatilayotgan paytda skrinshot va ekran yozuvi taqiqlanadi.
    SecureScreen.enable();
    // Pleyer sahifasi doim vertikal: gorizontal faqat to'liq ekran tugmasi orqali.
    // (Aks holda telefon burilganda sahifa o'zini qayta qurib, o'tish sekin va notekis ko'rinadi.)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);

    // Arguments: {seriesId, episodeId?, title?} yoki eski usulda faqat seriesId (int).
    final args = Get.arguments;
    int? startEpisodeId;
    if (args is Map) {
      currentSeriesId.value = args['seriesId'] as int;
      startEpisodeId = args['episodeId'] as int?;
      seriesTitle.value = (args['title'] as String?)?.trim() ?? '';
    } else if (args is int) {
      currentSeriesId.value = args;
    }
    if (currentSeriesId.value != 0) {
      fetchEpisodes(currentSeriesId.value, startEpisodeId: startEpisodeId);
    }

    // Har 15 soniyada ko'rish joyini serverga yuboramiz ("Ko'rishni davom etish" uchun).
    _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) => _saveProgress());

    // Qism oxirigacha ko'rilsa — keyingisini avtomatik boshlaymiz.
    _completedSub = player.stream.completed.listen((done) {
      if (done) _playNext();
    });
    _bufferingSub = player.stream.buffering.listen(_onBuffering);
  }

  StreamSubscription<bool>? _completedSub;

  /// Fasl va qism raqami bo'yicha keyingi ko'rish mumkin bo'lgan qism.
  EpisodeModel? get nextEpisode {
    final current = currentEpisode.value;
    if (current == null) return null;
    final ordered = episodes.toList()
      ..sort((a, b) {
        final s = (a.seasonNumber ?? 1).compareTo(b.seasonNumber ?? 1);
        return s != 0 ? s : (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
      });
    final i = ordered.indexWhere((e) => e.id == current.id);
    if (i < 0) return null;
    return ordered.sublist(i + 1).firstWhereOrNull((e) => e.canWatch && e.videoUrl != null);
  }

  Future<void> _playNext() async {
    final next = nextEpisode;
    if (next == null) {
      // Bepul qism tugadi, keyingilari qulfli — to'lov oynasini taklif qilamiz.
      if (_hasLockedAfterCurrent) showUnlockSheetFor(currentSeriesId.value);
      return;
    }
    // Tugagan qismni "to'liq ko'rildi" deb saqlaymiz.
    await _saveProgress();
    appSnack('Keyingi qism'.tr, next.title ?? '@n-qism'.trParams({'n': '${next.episodeNumber}'}),
        duration: const Duration(seconds: 2));
    selectedSeason.value = next.seasonNumber;
    // Yangi qism boshidan boshlanadi (oldin qisman ko'rilgan bo'lsa ham).
    await playEpisode(next, fromStart: true);
  }

  Future<void> fetchEpisodes(int seriesId, {int? startEpisodeId}) async {
    try {
      isLoading(true);
      episodes.value = await _apiProvider.getEpisodes(seriesId);

      if (episodes.isNotEmpty) {
        final start = episodes.firstWhereOrNull((e) => e.id == startEpisodeId) ??
            episodes.firstWhereOrNull((e) => e.canWatch) ??
            episodes.first;
        selectedSeason.value = start.seasonNumber;
        playEpisode(start);
      }
    } catch (e) {
      // Internet yo'q, lekin qism yuklab olingan bo'lsa — oflayn ijro etamiz.
      final dl = Get.find<DownloadController>()
          .downloads
          .firstWhereOrNull((d) => d.episodeId == startEpisodeId && d.complete);
      if (dl != null) {
        final offline = EpisodeModel(
          id: dl.episodeId,
          seriesId: dl.seriesId,
          title: dl.title,
          thumbnail: dl.thumbnail,
          hasAccess: true,
          videoUrl: 'offline',
        );
        episodes.value = [offline];
        playEpisode(offline);
      } else {
        appSnack('Xato'.tr, 'Qismlarni yuklashda xatolik'.tr);
      }
    } finally {
      isLoading(false);
    }
  }

  bool get _hasLockedAfterCurrent {
    final current = currentEpisode.value;
    if (current == null) return false;
    int key(EpisodeModel e) => (e.seasonNumber ?? 1) * 100000 + (e.episodeNumber ?? 0);
    return episodes.any((e) => !e.canWatch && key(e) > key(current));
  }

  /// To'lov sahifasidan qaytganda qismlar ro'yxatini yangilaymiz — to'lov o'tgan bo'lsa
  /// qulflar darhol ochiladi. Hozir o'ynayotgan video to'xtamaydi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || currentSeriesId.value == 0) return;
    _apiProvider.getEpisodes(currentSeriesId.value).then((list) {
      if (list.isNotEmpty) episodes.value = list;
    }).catchError((_) {});
  }

  Future<void> playEpisode(EpisodeModel episode, {bool fromStart = false}) async {
    if (!episode.canWatch || episode.videoUrl == null) {
      // Qulfli qism — xabar o'rniga to'g'ridan-to'g'ri to'lov oynasi.
      await showUnlockSheetFor(currentSeriesId.value);
      return;
    }
    await _saveProgress();
    currentEpisode.value = episode;
    qualities.clear();

    // Yuklangan (shifrlangan) bo'lsa — lokal serverdan, internetsiz ijro etamiz.
    final offlineUrl = await Get.find<DownloadController>().playbackUrl(episode.id!);
    final isOffline = offlineUrl != null;

    String url = offlineUrl ?? episode.videoUrl!;
    playingHeight.value = 0;
    if (!isOffline) {
      // Sifatlar ro'yxatini olamiz va avval tanlangan sifat bo'lsa, o'shani ochamiz.
      qualities.value = await _loadQualities(episode.videoUrl!);
      final preferred = await _preferredHeight();
      final match = qualities.firstWhereOrNull((q) => q.height == preferred);
      selectedQuality.value = match?.height ?? 0;
      // "Avto": internet turiga qarab boshlang'ich sifatni o'zimiz tanlaymiz
      // (mpv o'zi har doim eng yuqori sifatni oladi va pasaytirmaydi).
      final chosen = match ?? await _autoQuality();
      if (chosen != null) {
        url = chosen.url;
        playingHeight.value = chosen.height;
      }
    }
    _stalls.clear();

    final resumeAt = fromStart ? 0 : (episode.watchedSeconds ?? 0);
    await _openAt(url, Duration(seconds: resumeAt > 5 ? resumeAt : 0));
  }

  // ───────────── ±10 soniya ─────────────

  Future<void> seekBy(int seconds) async {
    final s = player.state;
    var target = s.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (s.duration > Duration.zero && target > s.duration) target = s.duration;
    await player.seek(target);
  }

  // ───────────── Sifat ─────────────

  /// Mavjud sifatlar (Bunny HLS master playlist'dagi variantlar), balanddan pastga.
  var qualities = <VideoQuality>[].obs;

  /// Tanlangan sifat balandligi (masalan 720). 0 = Avto.
  var selectedQuality = 0.obs;

  static const _qualityPrefsKey = 'video_quality';

  /// Hozir aslida ijro etilayotgan sifat (Avto rejimida ham). 0 = noma'lum/oflayn.
  var playingHeight = 0.obs;

  Future<void> changeQuality(int height) async {
    final ep = currentEpisode.value;
    if (ep?.videoUrl == null || height == selectedQuality.value) return;
    selectedQuality.value = height;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_qualityPrefsKey, height);

    final chosen = height == 0
        ? await _autoQuality()
        : qualities.firstWhereOrNull((q) => q.height == height);
    if (chosen == null) return;
    playingHeight.value = chosen.height;
    _stalls.clear();
    // Joriy joydan davom ettiramiz.
    await _openAt(chosen.url, player.state.position);
  }

  /// Avto rejimda boshlang'ich sifat: Wi-Fi'da eng yuqorisi (720p gacha),
  /// mobil internetda 480p atrofi — tez-tez to'xtab yuklanmasligi uchun.
  Future<VideoQuality?> _autoQuality() async {
    if (qualities.isEmpty) return null;
    final net = await Connectivity().checkConnectivity();
    final wifi = net.contains(ConnectivityResult.wifi) || net.contains(ConnectivityResult.ethernet);
    final limit = wifi ? 720 : 480;
    // qualities balanddan pastga tartiblangan.
    return qualities.firstWhereOrNull((q) => q.height <= limit) ?? qualities.last;
  }

  // ───────────── Sekin internetda sifatni avtomatik pasaytirish ─────────────

  final _stalls = <DateTime>[];
  Timer? _stallTimer;
  bool _switching = false;
  StreamSubscription<bool>? _bufferingSub;

  void _onBuffering(bool buffering) {
    if (!buffering) {
      _stallTimer?.cancel();
      return;
    }
    // Faqat Avto rejimda, video boshlanganidan keyin (dastlabki yuklanish hisobga olinmaydi).
    if (selectedQuality.value != 0 || _switching || playingHeight.value == 0) return;
    if (player.state.position < const Duration(seconds: 3)) return;
    // Ochilish/sakrashdan keyingi 8 soniyadagi yuklanish normal holat.
    if (DateTime.now().difference(_openedAt) < const Duration(seconds: 8)) return;

    final now = DateTime.now();
    _stalls
      ..add(now)
      ..removeWhere((t) => now.difference(t) > const Duration(seconds: 60));
    // 1 daqiqada 3 marta to'xtasa yoki bir marta 5 soniyadan ko'p yuklansa — pasaytiramiz.
    if (_stalls.length >= 3) {
      _downgrade();
    } else {
      _stallTimer?.cancel();
      _stallTimer = Timer(const Duration(seconds: 5), _downgrade);
    }
  }

  Future<void> _downgrade() async {
    _stallTimer?.cancel();
    final lower = qualities.firstWhereOrNull((q) => q.height < playingHeight.value);
    if (lower == null || _switching) return;
    _switching = true;
    _stalls.clear();
    playingHeight.value = lower.height;
    appSnack('Internet sekin'.tr, 'Sifat @q ga tushirildi'.trParams({'q': lower.label}),
        duration: const Duration(seconds: 2));
    try {
      await _openAt(lower.url, player.state.position);
    } finally {
      _switching = false;
    }
  }

  Future<int> _preferredHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_qualityPrefsKey) ?? 0;
  }

  Future<List<VideoQuality>> _loadQualities(String masterUrl) async {
    try {
      final res = await Dio().get<String>(masterUrl, options: Options(responseType: ResponseType.plain));
      return VideoQuality.parseMaster(res.data ?? '', masterUrl);
    } catch (_) {
      return const [];
    }
  }

  int _openToken = 0;

  /// Videoni berilgan joydan ochadi.
  /// HLS da `Media.start` ishlamaydi, stream xabarini kutish esa ishonchsiz (xabar
  /// open() tugaguncha o'tib ketadi). Shuning uchun player holatini so'rab turamiz:
  /// video yuklanib, davomiyligi ma'lum bo'lgach seek qilamiz va natijani tekshiramiz.
  /// Video ochilayotgan/sakrayotgan payt — bu vaqtdagi yuklanish "to'xtash" hisoblanmaydi.
  DateTime _openedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _openAt(String url, Duration position) async {
    final token = ++_openToken;
    _openedAt = DateTime.now();
    await player.open(Media(url), play: true);
    if (position <= Duration.zero) return;

    for (var i = 0; i < 100; i++) {
      // Bu orada boshqa qism/sifat ochilgan bo'lsa — to'xtaymiz.
      if (token != _openToken) return;
      final s = player.state;
      if (s.duration > Duration.zero && !s.buffering) {
        await player.seek(position);
        _openedAt = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 400));
        // Seek qabul qilinganini tekshiramiz, bo'lmasa yana urinamiz.
        if ((player.state.position - position).inSeconds.abs() <= 5) return;
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _saveProgress() async {
    final ep = currentEpisode.value;
    final pos = player.state.position.inSeconds;
    if (ep?.id == null || pos <= 0) return;
    try {
      await _apiProvider.saveProgress(currentSeriesId.value, ep!.id!, pos);
    } catch (_) {
      // Progressni saqlay olmaslik tomosha qilishga xalaqit bermasligi kerak.
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    SecureScreen.disable();
    // Boshqa sahifalar uchun cheklovni olib tashlaymiz va tizim panellarini qaytaramiz.
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _progressTimer?.cancel();
    _completedSub?.cancel();
    _bufferingSub?.cancel();
    _stallTimer?.cancel();
    _saveProgress();
    player.dispose();
    super.onClose();
  }
}
