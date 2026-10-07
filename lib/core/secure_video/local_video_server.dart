import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'video_key_store.dart';

class LocalVideoServer {
  LocalVideoServer._();
  static final instance = LocalVideoServer._();

  HttpServer? _server;
  late final String _token = _randomToken();

  static String _randomToken() {
    final r = Random.secure();
    return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  Future<String> playlistUrl(int episodeId) async {
    final server = await _ensureStarted();
    return 'http://127.0.0.1:${server.port}/$_token/$episodeId/index.m3u8';
  }

  Future<HttpServer> _ensureStarted() async {
    if (_server != null) return _server!;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
    _server = server;
    return server;
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      final seg = req.uri.pathSegments;
      if (seg.length != 3 || seg[0] != _token) {
        res.statusCode = HttpStatus.notFound;
        return;
      }
      final episodeId = int.tryParse(seg[1]);
      final name = seg[2];
      if (episodeId == null) {
        res.statusCode = HttpStatus.notFound;
        return;
      }
      final dir = await episodeDir(episodeId);

      if (name == 'index.m3u8') {
        final file = File(p.join(dir.path, 'index.m3u8'));
        if (!await file.exists()) {
          res.statusCode = HttpStatus.notFound;
          return;
        }
        final lines = (await file.readAsString()).split('\n');
        final out = <String>[];
        for (final l in lines) {
          out.add(l);
          if (l.startsWith('#EXT-X-MEDIA-SEQUENCE')) {
            out.add('#EXT-X-KEY:METHOD=AES-128,URI="key"');
          }
        }
        res.headers.contentType = ContentType('application', 'vnd.apple.mpegurl');
        res.write(out.join('\n'));
      } else if (name == 'key') {
        final key = await VideoKeyStore.get(episodeId);
        if (key == null) {
          res.statusCode = HttpStatus.notFound;
          return;
        }
        res.headers.contentType = ContentType.binary;
        res.add(key);
      } else {
        final m = RegExp(r'^seg_(\d+)\.ts$').firstMatch(name);
        final file = m == null ? null : File(p.join(dir.path, 's${m.group(1)}.bin'));
        if (file == null || !await file.exists()) {
          res.statusCode = HttpStatus.notFound;
          return;
        }
        res.headers.contentType = ContentType('video', 'mp2t');
        res.headers.contentLength = await file.length();
        await res.addStream(file.openRead());
      }
    } catch (_) {
      res.statusCode = HttpStatus.internalServerError;
    } finally {
      await res.close();
    }
  }

  static Future<Directory> episodeDir(int episodeId) async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'offline', 'e$episodeId'));
  }

  static Future<Directory> rootDir() async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'offline'));
  }
}
