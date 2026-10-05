import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Har bir yuklangan qism uchun alohida AES-128 kalit.
/// Kalitlar Android Keystore bilan himoyalangan xotirada saqlanadi — fayllarni
/// telefondan ko'chirib olishsa ham, kalitsiz ular ochilmaydi.
class VideoKeyStore {
  static const _storage = FlutterSecureStorage();
  static String _name(int episodeId) => 'video_key_$episodeId';

  static Future<Uint8List> getOrCreate(int episodeId) async {
    final existing = await get(episodeId);
    if (existing != null) return existing;
    final rnd = Random.secure();
    final key = Uint8List.fromList(List.generate(16, (_) => rnd.nextInt(256)));
    await _storage.write(key: _name(episodeId), value: base64Encode(key));
    return key;
  }

  static Future<Uint8List?> get(int episodeId) async {
    final v = await _storage.read(key: _name(episodeId));
    return v == null ? null : base64Decode(v);
  }

  static Future<void> delete(int episodeId) => _storage.delete(key: _name(episodeId));
}
