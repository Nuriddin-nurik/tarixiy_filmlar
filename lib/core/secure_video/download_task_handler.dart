import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'secure_hls_downloader.dart';
import 'video_key_store.dart';

/// Foreground service ishga tushganda chaqiriladi (alohida Flutter engine'da).
@pragma('vm:entry-point')
void startDownloadService() {
  FlutterForegroundTask.setTaskHandler(DownloadTaskHandler());
}

/// Yuklash navbati — ilova yopilganda ham shu yerda davom etadi.
///
/// Asosiy ilova bilan aloqa (Map xabarlar):
///   ilova → xizmat: {'cmd': 'add', 'job': {...}}, {'cmd': 'cancel', 'id': 1}, {'cmd': 'status'}
///   xizmat → ilova: {'id': 1, 'p': 0.42}, {'id': 1, 'done': true}, {'id': 1, 'error': true},
///                   {'status': [1, 2]}  (navbatdagi va yuklanayotgan qismlar)
class DownloadTaskHandler extends TaskHandler {
  static const queueKey = 'download_queue';

  final List<DownloadJob> _queue = [];
  DownloadJob? _current;
  SecureDownloadTask? _task;
  int _lastPercent = -1;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final raw = await FlutterForegroundTask.getData<String>(key: queueKey);
    if (raw != null) {
      _queue.addAll((jsonDecode(raw) as List).map((e) => DownloadJob.fromJson(e)));
    }
    _sendStatus();
    _next();
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map) return;
    switch (data['cmd']) {
      case 'add':
        final job = DownloadJob.fromJson(Map<String, dynamic>.from(data['job']));
        if (_current?.episodeId != job.episodeId && !_queue.any((j) => j.episodeId == job.episodeId)) {
          _queue.add(job);
          _persist();
        }
        if (_current == null) _next();
        _sendStatus();
        break;
      case 'cancel':
        final id = data['id'];
        _queue.removeWhere((j) => j.episodeId == id);
        _persist();
        if (_current?.episodeId == id) {
          _task?.cancel(); // natija false bo'ladi, _next() o'zi chaqiriladi
        }
        _sendStatus();
        break;
      case 'status':
        _sendStatus();
        break;
    }
  }

  Future<void> _next() async {
    if (_current != null) return;
    if (_queue.isEmpty) {
      await FlutterForegroundTask.removeData(key: queueKey);
      await FlutterForegroundTask.stopService();
      return;
    }
    final job = _queue.first;
    _current = job;
    _lastPercent = -1;
    _updateNotification(job, 0);

    bool ok = false;
    try {
      final key = await VideoKeyStore.getOrCreate(job.episodeId);
      _task = await SecureHlsDownloader.start(
        mediaPlaylistUrl: job.mediaUrl,
        dirPath: job.dirPath,
        key: key,
        onProgress: (p) {
          FlutterForegroundTask.sendDataToMain({'id': job.episodeId, 'p': p});
          _updateNotification(job, p);
        },
      );
      ok = await _task!.result;
    } catch (_) {
      ok = false;
    }

    final cancelled = !_queue.any((j) => j.episodeId == job.episodeId);
    _queue.removeWhere((j) => j.episodeId == job.episodeId);
    await _persist();
    _current = null;
    _task = null;

    if (!cancelled) {
      FlutterForegroundTask.sendDataToMain(ok ? {'id': job.episodeId, 'done': true} : {'id': job.episodeId, 'error': true});
    }
    _sendStatus();
    _next();
  }

  void _updateNotification(DownloadJob job, double p) {
    final percent = (p * 100).floor();
    if (percent == _lastPercent) return; // bildirishnomani har bo'lakda yangilamaymiz
    _lastPercent = percent;
    final more = _queue.length > 1 ? ' (+${_queue.length - 1})' : '';
    FlutterForegroundTask.updateService(
      notificationTitle: job.title,
      notificationText: '$percent%$more',
    );
  }

  void _sendStatus() {
    FlutterForegroundTask.sendDataToMain({
      'status': [if (_current != null) _current!.episodeId, ..._queue.map((j) => j.episodeId)],
    });
  }

  Future<void> _persist() async {
    await FlutterForegroundTask.saveData(
      key: queueKey,
      value: jsonEncode(_queue.map((j) => j.toJson()).toList()),
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _task?.cancel();
  }
}

class DownloadJob {
  final int episodeId;
  final String mediaUrl;
  final String dirPath;
  final String title;

  DownloadJob({required this.episodeId, required this.mediaUrl, required this.dirPath, required this.title});

  Map<String, dynamic> toJson() => {'episodeId': episodeId, 'mediaUrl': mediaUrl, 'dirPath': dirPath, 'title': title};

  factory DownloadJob.fromJson(Map<String, dynamic> j) => DownloadJob(
        episodeId: j['episodeId'],
        mediaUrl: j['mediaUrl'],
        dirPath: j['dirPath'],
        title: j['title'] ?? '',
      );
}
