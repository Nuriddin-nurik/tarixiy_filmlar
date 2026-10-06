import 'package:flutter/services.dart';

/// Skrinshot va ekran yozuvini taqiqlash (Android FLAG_SECURE).
/// Faqat video pleyer ochiq paytda yoqiladi — boshqa ekranlarda skrinshot olish mumkin.
class SecureScreen {
  static const _channel = MethodChannel('tarixiy/secure');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {}
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {}
  }
}
