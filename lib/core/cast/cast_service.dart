import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:get/get.dart';

import 'dlna_client.dart';

class CastDevice {
  final String id;
  final String name;
  final String? subtitle;
  final GoogleCastDevice? google;
  final DlnaDevice? dlna;

  const CastDevice({required this.id, required this.name, this.subtitle, this.google, this.dlna});
}

class CastMedia {
  final String id;
  final String url;
  final String title;
  final String subtitle;
  final String? thumbnail;
  final Duration duration;

  const CastMedia({
    required this.id,
    required this.url,
    required this.title,
    required this.subtitle,
    this.thumbnail,
    this.duration = Duration.zero,
  });
}

class CastService extends GetxService {
  static CastService get to => Get.find<CastService>();

  final available = false.obs;
  final connected = false.obs;
  final deviceName = ''.obs;
  final searching = false.obs;
  final devices = <CastDevice>[].obs;

  final playing = false.obs;
  final buffering = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  final _finished = StreamController<void>.broadcast();
  Stream<void> get finished => _finished.stream;

  bool _googleReady = false;
  final _googleDevices = <GoogleCastDevice>[];
  final _dlnaDevices = <String, DlnaDevice>{};
  final _dlnaClient = DlnaClient();

  DlnaDevice? _dlna;
  Timer? _dlnaPoll;
  bool _dlnaPolling = false;
  int _dlnaFailures = 0;
  bool _dlnaWasPlaying = false;
  bool _dlnaLoading = false;
  Duration _dlnaLastPosition = Duration.zero;

  StreamSubscription<GoogleCastSession?>? _sessionSub;
  StreamSubscription<List<GoogleCastDevice>>? _devicesSub;
  StreamSubscription<GoggleCastMediaStatus?>? _statusSub;
  StreamSubscription<Duration>? _positionSub;

  bool get isDlna => _dlna != null;

  Future<CastService> init() async {
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) return this;
    try {
      if (kReleaseMode) GoogleCastLogger.level = CastLogLevel.none;
      const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
      final GoogleCastOptions options = GetPlatform.isIOS
          ? IOSGoogleCastOptions(
              GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
              stopCastingOnAppTerminated: true,
            )
          : GoogleCastOptionsAndroid(appId: appId, stopCastingOnAppTerminated: true);
      await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
      _sessionSub = GoogleCastSessionManager.instance.currentSessionStream.listen(_onSession);
      _devicesSub = GoogleCastDiscoveryManager.instance.devicesStream.listen((list) {
        _googleDevices
          ..clear()
          ..addAll(list);
        _rebuildDevices();
      });
      _statusSub = GoogleCastRemoteMediaClient.instance.mediaStatusStream.listen(_onGoogleStatus);
      _positionSub = GoogleCastRemoteMediaClient.instance.playerPositionStream.listen((p) {
        if (connected.value && !isDlna) position.value = p;
      });
      _googleReady = true;
    } catch (_) {
      _googleReady = false;
    }
    available.value = _googleReady || GetPlatform.isAndroid;
    return this;
  }

  void _rebuildDevices() {
    final googleNames = _googleDevices.map((d) => d.friendlyName.toLowerCase()).toSet();
    devices.assignAll([
      for (final d in _googleDevices)
        CastDevice(id: 'g:${d.deviceID}', name: d.friendlyName, subtitle: d.modelName, google: d),
      for (final d in _dlnaDevices.values)
        if (!googleNames.contains(d.name.toLowerCase()))
          CastDevice(id: 'd:${d.id}', name: d.name, subtitle: d.model.isEmpty ? null : d.model, dlna: d),
    ]);
  }

  void _onSession(GoogleCastSession? session) {
    if (isDlna) return;
    final isConnected = session?.connectionState == GoogleCastConnectState.connected;
    deviceName.value = isConnected ? (session?.device?.friendlyName ?? '') : '';
    connected.value = isConnected;
  }

  void _onGoogleStatus(GoggleCastMediaStatus? status) {
    if (isDlna || !connected.value || status == null) return;
    final state = status.playerState;
    playing.value = state == CastMediaPlayerState.playing;
    buffering.value = state == CastMediaPlayerState.buffering || state == CastMediaPlayerState.loading;
    final d = status.mediaInformation?.duration;
    if (d != null && d > Duration.zero) duration.value = d;
    if (state == CastMediaPlayerState.idle && status.idleReason == GoogleCastMediaIdleReason.finished) {
      _finished.add(null);
    }
  }

  Future<void> startDiscovery() async {
    if (!available.value) return;
    if (_googleReady) {
      try {
        await GoogleCastDiscoveryManager.instance.startDiscovery(activeScan: true);
      } catch (_) {
      }
    }
    if (!GetPlatform.isAndroid || searching.value) return;
    searching.value = true;
    try {
      await _dlnaClient.search((d) {
        _dlnaDevices[d.id] = d;
        _rebuildDevices();
      });
    } catch (_) {
    } finally {
      searching.value = false;
    }
  }

  Future<void> stopDiscovery() async {
    if (!_googleReady) return;
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
    } catch (_) {
    }
  }

  Future<bool> connect(CastDevice device) async {
    final google = device.google;
    if (google != null) {
      if (isDlna) await disconnect();
      try {
        return await GoogleCastSessionManager.instance.startSessionWithDevice(google);
      } catch (_) {
        return false;
      }
    }
    final dlna = device.dlna;
    if (dlna == null) return false;
    try {
      await _dlnaClient.status(dlna);
    } catch (_) {
      return false;
    }
    if (connected.value) await disconnect();
    _dlna = dlna;
    _resetStatus();
    deviceName.value = dlna.name;
    connected.value = true;
    _dlnaPoll = Timer.periodic(const Duration(seconds: 1), (_) => _pollDlna());
    return true;
  }

  Future<void> disconnect() async {
    final dlna = _dlna;
    if (dlna != null) {
      _dlnaPoll?.cancel();
      _dlnaPoll = null;
      _dlna = null;
      try {
        await _dlnaClient.stop(dlna);
      } catch (_) {
      }
      deviceName.value = '';
      connected.value = false;
      return;
    }
    try {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    } catch (_) {
    }
  }

  void _resetStatus() {
    playing.value = false;
    buffering.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _dlnaWasPlaying = false;
    _dlnaFailures = 0;
    _dlnaLastPosition = Duration.zero;
  }

  Future<void> _pollDlna() async {
    final dlna = _dlna;
    if (dlna == null || _dlnaPolling || _dlnaLoading) return;
    _dlnaPolling = true;
    try {
      final s = await _dlnaClient.status(dlna);
      if (_dlna != dlna || _dlnaLoading) return;
      _dlnaFailures = 0;
      playing.value = s.playing;
      buffering.value = s.loading;
      if (s.duration > Duration.zero) duration.value = s.duration;
      if (s.playing || s.state == 'PAUSED_PLAYBACK') {
        position.value = s.position;
        _dlnaLastPosition = s.position;
      }
      if (s.playing) _dlnaWasPlaying = true;
      if (s.stopped && _dlnaWasPlaying) {
        _dlnaWasPlaying = false;
        final total = duration.value;
        if (total > Duration.zero && _dlnaLastPosition >= total - const Duration(seconds: 15)) {
          _finished.add(null);
        }
      }
    } catch (_) {
      if (_dlna == dlna && ++_dlnaFailures >= 8) await disconnect();
    } finally {
      _dlnaPolling = false;
    }
  }

  Future<void> load(CastMedia media, {Duration at = Duration.zero, double rate = 1.0}) async {
    final dlna = _dlna;
    position.value = at;
    duration.value = media.duration;
    if (dlna == null) {
      await GoogleCastRemoteMediaClient.instance.loadMedia(
        GoogleCastMediaInformation(
          contentId: media.id,
          contentUrl: Uri.parse(media.url),
          contentType: 'application/x-mpegURL',
          streamType: CastMediaStreamType.buffered,
          metadata: GoogleCastGenericMediaMetadata(
            title: media.title,
            subtitle: media.subtitle,
            images: media.thumbnail != null ? [GoogleCastImage(url: Uri.parse(media.thumbnail!))] : null,
          ),
        ),
        autoPlay: true,
        playPosition: at,
        playbackRate: rate,
      );
      return;
    }
    _dlnaLoading = true;
    _dlnaWasPlaying = false;
    buffering.value = true;
    playing.value = false;
    try {
      await _dlnaClient.load(dlna,
          url: media.url, title: media.title, thumbnail: media.thumbnail, duration: media.duration);
      await _dlnaClient.play(dlna);
      if (at > const Duration(seconds: 5)) {
        for (var i = 0; i < 30 && _dlna == dlna; i++) {
          await Future.delayed(const Duration(seconds: 1));
          try {
            if ((await _dlnaClient.status(dlna)).playing) break;
          } catch (_) {
          }
        }
        if (_dlna == dlna) await _dlnaClient.seek(dlna, at);
      }
    } finally {
      _dlnaLoading = false;
    }
  }

  Future<void> play() {
    final dlna = _dlna;
    return dlna != null ? _dlnaClient.play(dlna) : GoogleCastRemoteMediaClient.instance.play();
  }

  Future<void> pause() {
    final dlna = _dlna;
    return dlna != null ? _dlnaClient.pause(dlna) : GoogleCastRemoteMediaClient.instance.pause();
  }

  Future<void> seek(Duration to) {
    position.value = to;
    final dlna = _dlna;
    return dlna != null
        ? _dlnaClient.seek(dlna, to)
        : GoogleCastRemoteMediaClient.instance
            .seek(GoogleCastMediaSeekOption(position: to, resumeState: GoogleCastMediaResumeState.unchanged));
  }

  Future<void> setRate(double rate) async {
    if (isDlna) return;
    await GoogleCastRemoteMediaClient.instance.setPlaybackRate(rate);
  }

  @override
  void onClose() {
    _dlnaPoll?.cancel();
    _sessionSub?.cancel();
    _devicesSub?.cancel();
    _statusSub?.cancel();
    _positionSub?.cancel();
    _finished.close();
    super.onClose();
  }
}
