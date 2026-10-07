import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../../../core/widgets/app_widgets.dart';

class AccountView extends GetView<ProfileController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Hisob ma'lumotlari".tr)),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _field('Ism'.tr, user?.username ?? '—'),
          _field('Email', user?.email ?? '—'),
          _field('Foydalanuvchi ID'.tr, user?.userId?.toString() ?? '—', copyable: true),
          _field('Kirish usuli'.tr, 'Google'),
          SizedBox(height: 32.h),
          Text(
            'Xavfli hudud'.tr,
            style: TextStyle(color: AppColors.danger, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Obx(() => OutlinedButton.icon(
                onPressed: controller.isDeleting.value ? null : _confirmDelete,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(48.h),
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                icon: controller.isDeleting.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
                    : const Icon(Icons.delete_outline, color: AppColors.danger),
                label: Text("Akkauntni o'chirish".tr, style: const TextStyle(color: AppColors.danger)),
              )),
          SizedBox(height: 8.h),
          Text(
            "Akkaunt o'chirilsa, obunalar va ko'rish tarixi qayta tiklanmaydi.".tr,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text("Akkauntni o'chirish".tr, style: const TextStyle(color: Colors.white)),
      content: Text(
        "Rostdan ham akkauntingizni butunlay o'chirmoqchimisiz? Bu amalni ortga qaytarib bo'lmaydi.".tr,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('Bekor qilish'.tr, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteAccount();
          },
          child: Text("O'chirish".tr, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ));
  }

  Widget _field(String label, String value, {bool copyable = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 18.sp),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                appSnack('Nusxa olindi'.tr, value);
              },
            ),
        ],
      ),
    );
  }
}
