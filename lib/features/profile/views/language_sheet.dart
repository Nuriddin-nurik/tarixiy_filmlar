import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/i18n/locale_service.dart';
import '../../../core/theme/app_colors.dart';

/// Tilni tanlash oynasi.
Future<void> showLanguageSheet() {
  Widget option(Locale locale, String name, String flag) {
    final selected = Get.locale?.languageCode == locale.languageCode;
    return ListTile(
      onTap: () async {
        Get.back();
        await LocaleService.change(locale);
      },
      leading: Text(flag, style: TextStyle(fontSize: 22.sp)),
      title: Text(name, style: TextStyle(color: Colors.white, fontSize: 15.sp)),
      trailing: selected ? const Icon(Icons.check_circle, color: AppColors.greenLight) : null,
    );
  }

  return Get.bottomSheet(
    SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tilni tanlang'.tr,
                style: TextStyle(color: AppColors.gold, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            option(LocaleService.uz, "O'zbekcha", '🇺🇿'),
            option(LocaleService.ru, 'Русский', '🇷🇺'),
          ],
        ),
      ),
    ),
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
  );
}
