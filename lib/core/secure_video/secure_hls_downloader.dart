import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:pointycastle/export.dart';

class SecureHlsDownloader {
  static Future<SecureDownloadTask> start({
    required String mediaPlaylistUrl,
    required String dirPath,
    required Uint8List key,
    required void Function(double) onProgress,
  }) async {
    final receive = ReceivePort();
    final completer = Completer<bool>();
    final isolate = await Isolate.spawn(
      _run,
      _Job(receive.sendPort, mediaPlaylistUrl, dirPath, key),
      errorsAreFatal: true,
    );
    receive.listen((msg) {
      if (msg is double) {
        onProgress(msg);
      } else if (msg is bool) {
        if (!completer.isCompleted) completer.complete(msg);
        receive.close();
      }
    });
    return SecureDownloadTask._(isolate, receive, completer);
  }

  static List<HlsVariant> parseMaster(String content, String masterUrl) {
    final base = masterUrl.substring(0, masterUrl.lastIndexOf('/') + 1);
    final lines = content.split('\n').map((l) => l.trim()).toList();
    final out = <HlsVariant>[];
    for (var i = 0; i < lines.length - 1; i++) {
      if (!lines[i].startsWith('#EXT-X-STREAM-INF')) continue;
      final h = RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(lines[i]);
      final bw = RegExp(r'BANDWIDTH=(\d+)').firstMatch(lines[i]);
      final uri = lines[i + 1];
      if (h == null || uri.isEmpty || uri.startsWith('#')) continue;
      out.add(HlsVariant(
        int.parse(h.group(1)!),
        uri.startsWith('http') ? uri : base + uri,
        int.tryParse(bw?.group(1) ?? '') ?? 0,
      ));
    }
    out.sort((a, b) => a.height.compareTo(b.height));
    return out;
  }

  static Future<void> _run(_Job job) async {
    final send = job.port;
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final dir = Directory(job.dirPath);
      await dir.create(recursive: true);

      final res = await dio.get<String>(job.url, options: Options(responseType: ResponseType.plain));
      final lines = (res.data ?? '').split('\n').map((l) => l.trim()).toList();
      final base = job.url.substring(0, job.url.lastIndexOf('/') + 1);

      final segUrls = <String>[];
      final local = <String>[];
      for (final l in lines) {
        if (l.isEmpty) continue;
        if (l.startsWith('#EXT-X-KEY') || l.startsWith('#EXT-X-MEDIA-SEQUENCE')) continue;
        if (l.startsWith('#')) {
          local.add(l);
          if (l.startsWith('#EXTM3U')) local.add('#EXT-X-MEDIA-SEQUENCE:0');
        } else {
          local.add('seg_${segUrls.length}.ts');
          segUrls.add(l.startsWith('http') ? l : base + l);
        }
      }
      if (segUrls.isEmpty) throw Exception('Playlist bo\'sh');
      if (!local.contains('#EXT-X-ENDLIST')) local.add('#EXT-X-ENDLIST');

      var done = 0;
      var next = 0;
      Future<void> worker() async {
        while (true) {
          final i = next++;
          if (i >= segUrls.length) return;
          final out = File(p.join(dir.path, 's$i.bin'));
          if (!await out.exists()) {
            final bytes = await _downloadWithRetry(dio, segUrls[i]);
            final enc = encryptSegment(bytes, job.key, i);
            final tmp = File('${out.path}.tmp');
            await tmp.writeAsBytes(enc, flush: true);
            await tmp.rename(out.path);
          }
          done++;
          send.send(done / segUrls.length);
        }
      }

      await Future.wait(List.generate(4, (_) => worker()));

      await File(p.join(dir.path, 'index.m3u8')).writeAsString(local.join('\n'));
      await File(p.join(dir.path, 'complete')).writeAsString('ok');
      send.send(true);
    } catch (_) {
      send.send(false);
    }
  }

  static Future<Uint8List> _downloadWithRetry(Dio dio, String url) async {
    for (var attempt = 1;; attempt++) {
      try {
        final r = await dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList(r.data!);
      } catch (e) {
        if (attempt >= 4) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  static Uint8List encryptSegment(Uint8List data, Uint8List key, int sequence) {
    final iv = Uint8List(16);
    var s = sequence;
    for (var b = 15; b >= 0 && s > 0; b--) {
      iv[b] = s & 0xff;
      s >>= 8;
    }
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()))
      ..init(
        true,
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ParametersWithIV(KeyParameter(key), iv),
          null,
        ),
      );
    return cipher.process(data);
  }
}

class HlsVariant {
  final int height;
  final String url;
  final int bandwidth;
  HlsVariant(this.height, this.url, this.bandwidth);

  int? sampledBytes;

  double estimateMb(int durationSeconds) => sampledBytes != null
      ? sampledBytes! / 1024 / 1024
      : bandwidth * durationSeconds / 8 / 1024 / 1024;

  Future<void> sampleSize(Dio dio, {int samples = 8}) async {
    try {
      final res = await dio.get<String>(url, options: Options(responseType: ResponseType.plain));
      final base = url.substring(0, url.lastIndexOf('/') + 1);
      final segs = (res.data ?? '')
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .map((l) => l.startsWith('http') ? l : base + l)
          .toList();
      if (segs.isEmpty) return;
      final n = samples.clamp(1, segs.length);
      final picks = List.generate(n, (i) => segs[(i * (segs.length - 1) / (n == 1 ? 1 : n - 1)).round()]);
      final sizes = await Future.wait(picks.map((u) async {
        final h = await dio.head(u);
        return int.tryParse(h.headers.value('content-length') ?? '') ?? 0;
      }));
      final valid = sizes.where((s) => s > 0).toList();
      if (valid.isEmpty) return;
      final avg = valid.reduce((a, b) => a + b) / valid.length;
      sampledBytes = (avg * segs.length).round();
    } catch (_) {
    }
  }
}

class SecureDownloadTask {
  SecureDownloadTask._(this._isolate, this._port, this._done);
  final Isolate _isolate;
  final ReceivePort _port;
  final Completer<bool> _done;

  Future<bool> get result => _done.future;

  void cancel() {
    _isolate.kill(priority: Isolate.immediate);
    _port.close();
    if (!_done.isCompleted) _done.complete(false);
  }
}

class _Job {
  final SendPort port;
  final String url;
  final String dirPath;
  final Uint8List key;
  _Job(this.port, this.url, this.dirPath, this.key);
}
