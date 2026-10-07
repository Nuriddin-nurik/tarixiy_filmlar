import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'app_locale';
  static const uz = Locale('uz', 'UZ');
  static const ru = Locale('ru', 'RU');

  static Future<Locale> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == 'ru' ? ru : uz;
  }

  static Future<void> change(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    await Get.updateLocale(locale);
  }

  static bool get isRussian => Get.locale?.languageCode == 'ru';

  static String get currentName => isRussian ? 'Русский' : "O'zbekcha";
}
