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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Hisob ma'lumotlari".tr)),
      body: Obx(() => _body()),
    );
  }

  Widget _body() {
    final user = controller.user;
    final isTelegram = user?.isTelegramAccount ?? false;
    final hasTelegram = user?.telegramChatId != null;
    return ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _field('Ism'.tr, user?.username ?? '—'),
          if (user?.isTelegramAccount ?? false) ...[
            _field('Telegram ID', user?.telegramChatId?.toString() ?? '—', copyable: true),
            if (user?.telegramUsername != null) _field('Telegram', '@${user!.telegramUsername}'),
          ] else
            _field('Email', user?.email ?? '—'),
          _field('Foydalanuvchi ID'.tr, user?.id?.toString() ?? '—', copyable: true),
          _field('Kirish usuli'.tr, (user?.isTelegramAccount ?? false) ? 'Telegram' : 'Google'),
          SizedBox(height: 24.h),
          Text(
            "Bog'langan akkauntlar".tr,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          _linkRow(
            icon: 'google',
            title: 'Google',
            value: isTelegram ? null : user?.email,
            loading: controller.isLinkingGoogle.value,
            onLink: controller.linkGoogle,
          ),
          _linkRow(
            icon: 'telegram',
            title: 'Telegram',
            value: hasTelegram
                ? (user?.telegramUsername != null ? '@${user!.telegramUsername}' : 'ID: ${user?.telegramChatId}')
                : null,
            loading: controller.isLinkingTelegram.value,
            onLink: controller.linkTelegram,
            onCancel: controller.cancelTelegramLink,
          ),
          if (hasTelegram)
            OutlinedButton.icon(
              onPressed: controller.isSyncingBot.value
                  ? null
                  : () => controller.syncBotSubscriptions(manual: true),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(44.h),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: controller.isSyncingBot.value
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.seriesGreen))
                  : Icon(Icons.refresh_rounded, color: AppColors.seriesGreen, size: 18.sp),
              label: Text(
                'Botdagi obunalarni yangilash'.tr,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ),
          SizedBox(height: 6.h),
          Text(
            "Ikkalasini ulasangiz, Google yoki Telegram bilan kirganda ham bitta hisobga tushasiz va botdagi obunalaringiz shu yerda ochiladi.".tr,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
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
    );
  }

  Widget _linkRow({
    required String icon,
    required String title,
    required String? value,
    required bool loading,
    required VoidCallback onLink,
    VoidCallback? onCancel,
  }) {
    final linked = value != null;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(
                  linked ? value : 'Ulanmagan'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (linked)
            Icon(Icons.check_circle_rounded, color: AppColors.seriesGreen, size: 20.sp)
          else if (loading)
            TextButton(
              onPressed: onCancel,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.seriesGreen),
                  ),
                  if (onCancel != null) ...[
                    SizedBox(width: 6.w),
                    Text('Bekor qilish'.tr, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                  ],
                ],
              ),
            )
          else
            TextButton(
              onPressed: onLink,
              child: Text('Ulash'.tr, style: TextStyle(color: AppColors.seriesGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
