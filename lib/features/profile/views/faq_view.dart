import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _items = [
    (
      'Obunani qanday sotib olaman?',
      "Profil → Premium obuna → «Ulanish» tugmasini bosing, muddatni tanlang va Pixy orqali to'lang. To'lovdan so'ng ilovaga qaytib, sahifani yangilang."
    ),
    (
      "Bepul qismlar bormi?",
      "Ha. Ko'p seriallarning dastlabki qismlari bepul. Ular serial sahifasida «Bepul» belgisi bilan ko'rsatilgan."
    ),
    (
      "Qismni internetsiz ko'rsa bo'ladimi?",
      "Ha. Pleyer sahifasida qism yonidagi yuklab olish tugmasini bosing. Yuklangan qismlar faqat shu ilova ichida ko'rinadi."
    ),
    (
      'Nega boshqa telefonda kira olmayapman?',
      "Xavfsizlik uchun bitta akkaunt bir vaqtda bitta qurilmada ishlaydi. Yangi qurilmada kirsangiz, eski qurilmadagi sessiya yopiladi."
    ),
    (
      "To'lov qildim, lekin serial ochilmadi",
      "Sahifani pastga tortib yangilang. Muammo davom etsa, Qo'llab-quvvatlash orqali foydalanuvchi ID raqamingizni yuboring."
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('FAQ'.tr)),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) {
          final (q, a) = _items[i];
          return Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.textSecondary,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(q.tr, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              children: [
                Text(a.tr, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp, height: 1.45)),
              ],
            ),
          );
        },
      ),
    );
  }
}
