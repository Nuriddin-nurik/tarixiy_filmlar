import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Qurilma uchun barqaror ID. Birinchi chaqiruvda yaratiladi va saqlanadi,
/// keyin har doim o'sha qiymat qaytariladi. Backend login paytida shu ID ni
/// userga biriktiradi va har bir so'rovda X-Device-Id header orqali tekshiradi.
class DeviceId {
  static const _key = 'device_id';

  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final rnd = Random.secure();
    final id = List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await prefs.setString(_key, id);
    return id;
  }
}
