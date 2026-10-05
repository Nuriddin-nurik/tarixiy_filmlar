import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../data/models/episode_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/widgets/app_widgets.dart';
import 'download_controller.dart';

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

class PlayerController extends GetxController {
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
    if (next == null) return;
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

  Future<void> playEpisode(EpisodeModel episode, {bool fromStart = false}) async {
    if (!episode.canWatch || episode.videoUrl == null) {
      appSnack('Qism yopiq'.tr, "Bu qismni ko'rish uchun obuna bo'ling".tr);
      return;
    }
    await _saveProgress();
    currentEpisode.value = episode;
    qualities.clear();

    // Yuklangan (shifrlangan) bo'lsa — lokal serverdan, internetsiz ijro etamiz.
    final offlineUrl = await Get.find<DownloadController>().playbackUrl(episode.id!);
    final isOffline = offlineUrl != null;

    String url = offlineUrl ?? episode.videoUrl!;
    if (!isOffline) {
      // Sifatlar ro'yxatini olamiz va avval tanlangan sifat bo'lsa, o'shani ochamiz.
      qualities.value = await _loadQualities(episode.videoUrl!);
      final preferred = await _preferredHeight();
      final match = qualities.firstWhereOrNull((q) => q.height == preferred);
      selectedQuality.value = match?.height ?? 0;
      if (match != null) url = match.url;
    }

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

  Future<void> changeQuality(int height) async {
    final ep = currentEpisode.value;
    if (ep?.videoUrl == null || height == selectedQuality.value) return;
    selectedQuality.value = height;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_qualityPrefsKey, height);

    final url = height == 0
        ? ep!.videoUrl!
        : qualities.firstWhere((q) => q.height == height).url;
    // Joriy joydan davom ettiramiz.
    await _openAt(url, player.state.position);
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
  Future<void> _openAt(String url, Duration position) async {
    final token = ++_openToken;
    await player.open(Media(url), play: true);
    if (position <= Duration.zero) return;

    for (var i = 0; i < 100; i++) {
      // Bu orada boshqa qism/sifat ochilgan bo'lsa — to'xtaymiz.
      if (token != _openToken) return;
      final s = player.state;
      if (s.duration > Duration.zero && !s.buffering) {
        await player.seek(position);
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
    _progressTimer?.cancel();
    _completedSub?.cancel();
    _saveProgress();
    player.dispose();
    super.onClose();
  }
}
