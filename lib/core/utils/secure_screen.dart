import 'package:flutter/services.dart';

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
