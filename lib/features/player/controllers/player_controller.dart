import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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

class VideoQuality {
  final int height;
  final String url;
  final int width;

  const VideoQuality(this.height, this.url, {this.width = 0});

  String get label => '${height}p';

  static List<VideoQuality> parseMaster(String content, String masterUrl) {
    final base = masterUrl.substring(0, masterUrl.lastIndexOf('/') + 1);
    final lines = content.split('\n').map((l) => l.trim()).toList();
    final result = <VideoQuality>[];
    for (var i = 0; i < lines.length - 1; i++) {
      if (!lines[i].startsWith('#EXT-X-STREAM-INF')) continue;
      final res = RegExp(r'RESOLUTION=(\d+)x(\d+)').firstMatch(lines[i]);
      final uri = lines[i + 1];
      if (res == null || uri.isEmpty || uri.startsWith('#')) continue;
      result.add(VideoQuality(int.parse(res.group(2)!), uri.startsWith('http') ? uri : base + uri,
          width: int.parse(res.group(1)!)));
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

  var currentTabIndex = 0.obs;

  Timer? _progressTimer;

  List<int> get seasons =>
      (episodes.map((e) => e.seasonNumber ?? 1).toSet().toList()..sort());

  static Future<void> enterFullscreen() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static Future<void> exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

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
    SecureScreen.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);

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

    _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) => _saveProgress());

    _completedSub = player.stream.completed.listen((done) {
      if (done) _playNext();
    });
    _bufferingSub = player.stream.buffering.listen(_onBuffering);
  }

  StreamSubscription<bool>? _completedSub;

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
      if (_hasLockedAfterCurrent) showUnlockSheetFor(currentSeriesId.value);
      return;
    }
    await _saveProgress();
    appSnack('Keyingi qism'.tr, next.title ?? '@n-qism'.trParams({'n': '${next.episodeNumber}'}),
        duration: const Duration(seconds: 2));
    selectedSeason.value = next.seasonNumber;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || currentSeriesId.value == 0) return;
    _apiProvider.getEpisodes(currentSeriesId.value).then((list) {
      if (list.isNotEmpty) episodes.value = list;
    }).catchError((_) {});
  }

  Future<void> playEpisode(EpisodeModel episode, {bool fromStart = false}) async {
    if (!episode.canWatch || episode.videoUrl == null) {
      await showUnlockSheetFor(currentSeriesId.value);
      return;
    }
    final sw = Stopwatch()..start();
    _logFirstFrame(sw);
    _saveProgress();
    currentEpisode.value = episode;
    qualities.clear();

    final results = await Future.wait<Object?>([
      Get.find<DownloadController>().playbackUrl(episode.id!),
      _loadQualities(episode.videoUrl!),
      _preferredHeight(),
      Connectivity().checkConnectivity(),
    ]);
    if (_closed || currentEpisode.value?.id != episode.id) return;
    final offlineUrl = results[0] as String?;
    final isOffline = offlineUrl != null;

    String url = offlineUrl ?? episode.videoUrl!;
    playingHeight.value = 0;
    if (!isOffline) {
      qualities.value = results[1] as List<VideoQuality>;
      final preferred = results[2] as int;
      final match = qualities.firstWhereOrNull((q) => q.height == preferred);
      selectedQuality.value = match?.height ?? 0;
      final chosen = match ?? _autoQualityFor(results[3] as List<ConnectivityResult>);
      if (chosen != null) {
        url = chosen.url;
        playingHeight.value = chosen.height;
      }
    }
    _stalls.clear();

    final resumeAt = fromStart ? 0 : (episode.watchedSeconds ?? 0);
    final size = qualities.firstWhereOrNull((q) => q.url == url);
    if (size != null) await _prepareSurface(size.width, size.height);
    if (!kReleaseMode) debugPrint('[player] tayyorgarlik ${sw.elapsedMilliseconds}ms');
    await _openAt(url, Duration(seconds: resumeAt > 5 ? resumeAt : 0));
    final next = nextEpisode;
    if (next?.videoUrl != null) _loadQualities(next!.videoUrl!);
  }

  void _logFirstFrame(Stopwatch sw) {
    if (kReleaseMode) return;
    late final StreamSubscription<Duration> sub;
    sub = player.stream.position.listen((p) {
      if (p > Duration.zero) {
        debugPrint('[player] video boshlandi ${sw.elapsedMilliseconds}ms (joy ${p.inSeconds}s)');
        sub.cancel();
      }
    });
    Future.delayed(const Duration(seconds: 20), () => sub.cancel());
  }

  Future<void> seekBy(int seconds) async {
    final s = player.state;
    var target = s.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (s.duration > Duration.zero && target > s.duration) target = s.duration;
    await player.seek(target);
  }

  var qualities = <VideoQuality>[].obs;

  var selectedQuality = 0.obs;
  final speed = 1.0.obs;
  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> setSpeed(double value) async {
    speed.value = value;
    await player.setRate(value);
  }

  static const _qualityPrefsKey = 'video_quality';

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
    await _openAt(chosen.url, player.state.position);
  }

  Future<VideoQuality?> _autoQuality() async =>
      _autoQualityFor(await Connectivity().checkConnectivity());

  VideoQuality? _autoQualityFor(List<ConnectivityResult> net) {
    if (qualities.isEmpty) return null;
    final wifi = net.contains(ConnectivityResult.wifi) || net.contains(ConnectivityResult.ethernet);
    final limit = wifi ? 720 : 480;
    return qualities.firstWhereOrNull((q) => q.height <= limit) ?? qualities.last;
  }

  final _stalls = <DateTime>[];
  Timer? _stallTimer;
  bool _switching = false;
  StreamSubscription<bool>? _bufferingSub;

  void _onBuffering(bool buffering) {
    if (!buffering) {
      _stallTimer?.cancel();
      return;
    }
    if (selectedQuality.value != 0 || _switching || playingHeight.value == 0) return;
    if (player.state.position < const Duration(seconds: 3)) return;
    if (DateTime.now().difference(_openedAt) < const Duration(seconds: 8)) return;

    final now = DateTime.now();
    _stalls
      ..add(now)
      ..removeWhere((t) => now.difference(t) > const Duration(seconds: 60));
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

  static final _http = Dio(BaseOptions(responseType: ResponseType.plain, connectTimeout: const Duration(seconds: 5)));
  static final _qualityCache = <String, Future<List<VideoQuality>>>{};

  Future<List<VideoQuality>> _loadQualities(String masterUrl) {
    return _qualityCache[masterUrl] ??= _http.get<String>(masterUrl).then(
      (res) => VideoQuality.parseMaster(res.data ?? '', masterUrl),
      onError: (_) {
        _qualityCache.remove(masterUrl);
        return const <VideoQuality>[];
      },
    );
  }

  static const _videoChannel = MethodChannel('com.alexmercerind/media_kit_video');

  Future<void> _prepareSurface(int width, int height) async {
    if (width <= 0 || height <= 0 || !GetPlatform.isAndroid) return;
    final native = player.platform;
    if (native is! NativePlayer) return;
    try {
      await videoController.platform.future.timeout(const Duration(seconds: 2));
      final handle = await player.handle;
      await _videoChannel.invokeMethod('VideoOutputManager.SetSurfaceSize', {
        'handle': handle.toString(),
        'width': width.toString(),
        'height': height.toString(),
      });
      for (var i = 0; i < 20; i++) {
        if (_closed) return;
        if (await native.getProperty('vo') == 'gpu') return;
        await Future.delayed(const Duration(milliseconds: 25));
      }
    } catch (_) {
    }
  }

  int _openToken = 0;

  DateTime _openedAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool _closed = false;

  Future<void> _openAt(String url, Duration position) async {
    if (_closed) return;
    final token = ++_openToken;
    _openedAt = DateTime.now();
    final native = player.platform;
    if (native is NativePlayer) {
      await native.setProperty('start', position > Duration.zero ? '${position.inSeconds}' : 'none');
    }
    await player.open(Media(url), play: true);
    if (speed.value != 1.0) await player.setRate(speed.value);
    if (position <= Duration.zero) return;

    for (var i = 0; i < 100; i++) {
      if (token != _openToken || _closed) return;
      final s = player.state;
      if (s.duration > Duration.zero && !s.buffering) {
        if ((s.position - position).inSeconds.abs() <= 5) return;
        await player.seek(position);
        _openedAt = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 400));
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
    }
  }

  @override
  void onClose() {
    _closed = true;
    WidgetsBinding.instance.removeObserver(this);
    SecureScreen.disable();
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
