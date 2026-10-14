import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

class UpdateService {
  static const _packageName = 'com.nuriddin.tarixiy_filmlar';
  static const _snoozeKey = 'update_snoozed';
  static bool _checked = false;

  static Future<void> check() async {
    if (_checked || !kReleaseMode || !GetPlatform.isAndroid) return;
    _checked = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;
      final version = info.availableVersionCode ?? 0;
      final prefs = await SharedPreferences.getInstance();
      final snoozed = prefs.getString(_snoozeKey)?.split('|');
      if (snoozed != null && snoozed.length == 2 && snoozed[0] == '$version') {
        final until = DateTime.fromMillisecondsSinceEpoch(int.tryParse(snoozed[1]) ?? 0);
        if (DateTime.now().isBefore(until)) return;
      }
      final update = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.system_update_rounded, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(child: Text('Yangi versiya chiqdi'.tr, style: const TextStyle(color: Colors.white))),
            ],
          ),
          content: Text(
            "Ilovaning yangi versiyasi mavjud. Yangi imkoniyatlar va tuzatishlardan foydalanish uchun yangilang.".tr,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Keyinroq'.tr, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Yangilash'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (update == true) {
        await openStore();
      } else {
        final until = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
        await prefs.setString(_snoozeKey, '$version|$until');
      }
    } catch (_) {
    }
  }

  static Future<void> openStore() async {
    final market = Uri.parse('market://details?id=$_packageName');
    try {
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
    }
    await launchUrl(
      Uri.parse('https://play.google.com/store/apps/details?id=$_packageName'),
      mode: LaunchMode.externalApplication,
    );
  }
}
