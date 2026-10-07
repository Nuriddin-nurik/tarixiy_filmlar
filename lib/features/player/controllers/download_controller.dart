import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/secure_video/download_task_handler.dart';
import '../../../core/secure_video/local_video_server.dart';
import '../../../core/secure_video/secure_hls_downloader.dart';
import '../../../core/secure_video/video_key_store.dart';
import '../../../core/widgets/app_widgets.dart';

class DownloadedEpisode {
  final int episodeId;
  final int seriesId;
  final String title;
  final String? seriesTitle;
  final String? thumbnail;
  final int quality;
  final String? mediaUrl;
  final bool complete;

  DownloadedEpisode({
    required this.episodeId,
    required this.seriesId,
    required this.title,
    this.seriesTitle,
    this.thumbnail,
    this.quality = 0,
    this.mediaUrl,
    this.complete = false,
  });

  DownloadedEpisode copyWith({bool? complete, int? quality, String? mediaUrl}) => DownloadedEpisode(
        episodeId: episodeId,
        seriesId: seriesId,
        title: title,
        seriesTitle: seriesTitle,
        thumbnail: thumbnail,
        quality: quality ?? this.quality,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        complete: complete ?? this.complete,
      );

  Map<String, dynamic> toJson() => {
        'episodeId': episodeId,
        'seriesId': seriesId,
        'title': title,
        'seriesTitle': seriesTitle,
        'thumbnail': thumbnail,
        'quality': quality,
        'mediaUrl': mediaUrl,
        'complete': complete,
      };

  factory DownloadedEpisode.fromJson(Map<String, dynamic> j) => DownloadedEpisode(
        episodeId: j['episodeId'],
        seriesId: j['seriesId'],
        title: j['title'] ?? '',
        seriesTitle: j['seriesTitle'],
        thumbnail: j['thumbnail'],
        quality: j['quality'] ?? 0,
        mediaUrl: j['mediaUrl'],
        complete: j['complete'] ?? false,
      );
}

class DownloadController extends GetxController {
  static const _prefsKey = 'downloads_v2';

  var downloadProgress = <int, double>{}.obs;
  var downloads = <DownloadedEpisode>[].obs;
  final _active = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    FlutterForegroundTask.addTaskDataCallback(_onServiceData);
    _loadSaved();
  }

  @override
  void onClose() {
    FlutterForegroundTask.removeTaskDataCallback(_onServiceData);
    super.onClose();
  }

  static void initService() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tarixiy_downloads',
        channelName: 'Yuklanmalar',
        channelDescription: 'Kinolarni yuklab olish jarayoni',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  bool isComplete(int episodeId) =>
      downloads.any((d) => d.episodeId == episodeId && d.complete);

  bool isDownloading(int episodeId) => _active.contains(episodeId);

  bool isPaused(int episodeId) =>
      !isDownloading(episodeId) && downloads.any((d) => d.episodeId == episodeId && !d.complete);

  Future<String?> playbackUrl(int episodeId) async {
    if (!isComplete(episodeId)) return null;
    return LocalVideoServer.instance.playlistUrl(episodeId);
  }

  Future<List<HlsVariant>> variants(String masterUrl) async {
    final dio = Dio();
    final res = await dio.get<String>(masterUrl, options: Options(responseType: ResponseType.plain));
    final list = SecureHlsDownloader.parseMaster(res.data ?? '', masterUrl);
    await Future.wait(list.map((v) => v.sampleSize(dio)));
    return list;
  }

  Future<void> startDownload(DownloadedEpisode info, HlsVariant variant) async {
    final id = info.episodeId;
    if (isDownloading(id)) return;

    final entry = info.copyWith(quality: variant.height, mediaUrl: variant.url, complete: false);
    downloads.removeWhere((d) => d.episodeId == id);
    downloads.add(entry);
    await _persist();
    await _enqueue(entry);
  }

  Future<void> resume(int episodeId) async {
    final entry = downloads.firstWhereOrNull((d) => d.episodeId == episodeId);
    if (entry?.mediaUrl == null || isDownloading(episodeId)) return;
    await _enqueue(entry!);
  }

  Future<void> _enqueue(DownloadedEpisode entry) async {
    final id = entry.episodeId;
    final dir = await LocalVideoServer.episodeDir(id);
    final job = DownloadJob(
      episodeId: id,
      mediaUrl: entry.mediaUrl!,
      dirPath: dir.path,
      title: entry.seriesTitle?.isNotEmpty == true ? '${entry.seriesTitle} — ${entry.title}' : entry.title,
    );
    await VideoKeyStore.getOrCreate(id);

    _active.add(id);
    downloadProgress[id] = downloadProgress[id] ?? 0;

    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({'cmd': 'add', 'job': job.toJson()});
      return;
    }
    await FlutterForegroundTask.saveData(
      key: DownloadTaskHandler.queueKey,
      value: jsonEncode([job.toJson()]),
    );
    final result = await FlutterForegroundTask.startService(
      serviceId: 4201,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: job.title,
      notificationText: '0%',
      callback: startDownloadService,
    );
    if (result is ServiceRequestFailure) {
      _active.remove(id);
      downloadProgress.remove(id);
      downloads.refresh();
      appSnack('Xato'.tr, 'Yuklab olishda xatolik yuz berdi'.tr);
    }
  }

  void _onServiceData(Object data) {
    if (data is! Map) return;
    if (data['status'] is List) {
      final ids = (data['status'] as List).cast<int>().toSet();
      _active
        ..clear()
        ..addAll(ids);
      downloadProgress.removeWhere((id, _) => !ids.contains(id));
      downloads.refresh();
      return;
    }
    final id = data['id'];
    if (id is! int) return;
    if (data['p'] is double) {
      _active.add(id);
      downloadProgress[id] = data['p'];
    } else if (data['done'] == true) {
      _active.remove(id);
      downloadProgress.remove(id);
      final i = downloads.indexWhere((d) => d.episodeId == id);
      if (i >= 0) downloads[i] = downloads[i].copyWith(complete: true);
      _persist();
      appSnack('Muvaffaqiyatli'.tr, "Qism yuklab olindi! Oflayn ko'rishingiz mumkin.".tr);
    } else if (data['error'] == true) {
      _active.remove(id);
      downloadProgress.remove(id);
      downloads.refresh();
      appSnack('Xato'.tr, "Yuklash to'xtadi. Davom ettirish uchun qayta bosing.".tr);
    }
  }

  Future<void> cancel(int episodeId) => delete(episodeId);

  Future<void> delete(int episodeId) async {
    if (_active.remove(episodeId) && await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({'cmd': 'cancel', 'id': episodeId});
      await Future.delayed(const Duration(milliseconds: 500));
    }
    downloadProgress.remove(episodeId);
    downloads.removeWhere((d) => d.episodeId == episodeId);
    await _persist();
    final dir = await LocalVideoServer.episodeDir(episodeId);
    if (await dir.exists()) await dir.delete(recursive: true);
    await VideoKeyStore.delete(episodeId);
  }

  Future<void> deleteAll() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.removeData(key: DownloadTaskHandler.queueKey);
      await FlutterForegroundTask.stopService();
    }
    for (final id in [...downloads.map((d) => d.episodeId), ..._active]) {
      await VideoKeyStore.delete(id);
    }
    _active.clear();
    downloads.clear();
    downloadProgress.clear();
    await _persist();
    final root = await LocalVideoServer.rootDir();
    if (await root.exists()) await root.delete(recursive: true);
  }

  Future<double> totalSizeMb() async {
    final dir = await LocalVideoServer.rootDir();
    if (!await dir.exists()) return 0;
    var bytes = 0;
    await for (final f in dir.list(recursive: true)) {
      if (f is File) bytes += await f.length();
    }
    return bytes / (1024 * 1024);
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      downloads.value = (jsonDecode(raw) as List).map((e) => DownloadedEpisode.fromJson(e)).toList();
    }
    var changed = false;
    for (var i = 0; i < downloads.length; i++) {
      final d = downloads[i];
      if (d.complete) continue;
      final dir = await LocalVideoServer.episodeDir(d.episodeId);
      if (await File(p.join(dir.path, 'complete')).exists()) {
        downloads[i] = d.copyWith(complete: true);
        changed = true;
      }
    }
    if (changed) await _persist();
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({'cmd': 'status'});
    }
    await prefs.remove('downloads');
    final legacy = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'movies'));
    if (await legacy.exists()) await legacy.delete(recursive: true);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(downloads.map((d) => d.toJson()).toList()));
  }
}
