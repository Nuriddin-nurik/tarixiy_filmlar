import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/i18n/locale_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import 'language_sheet.dart';
import '../../../core/utils/open_series.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/subscription_models.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  Future<void> _openSupport() async {
    final app = Uri.parse('tg://resolve?domain=${AppConfig.supportTelegram}');
    final web = Uri.parse('https://t.me/${AppConfig.supportTelegram}');
    // Telegram o'rnatilgan bo'lsa ilovada, bo'lmasa brauzerda ochiladi.
    if (!await launchUrl(app, mode: LaunchMode.externalApplication)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          // HomeController dagi ma'lumot yangilansa profil ham yangilanadi.
          Get.find<HomeController>().homeData.value;
          final user = controller.user;
          final name = (user?.username?.isNotEmpty ?? false) ? user!.username! : 'Mehmon'.tr;
          final initial = name.characters.first.toUpperCase();

          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            children: [
              Text(
                'PROFIL'.tr,
                style: TextStyle(color: AppColors.gold, fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              SizedBox(height: 20.h),

              // Foydalanuvchi
              Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Text(initial,
                        style: TextStyle(color: AppColors.gold, fontSize: 26.sp, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                        if (user?.email != null)
                          Text(user!.email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                        if (user?.userId != null)
                          Text('ID: ${user!.userId}',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Obuna kartasi (holat serverdan: GET /account/subscription)
              ..._subscriptionSection(controller.subscription.value),
              SizedBox(height: 20.h),

              _group([
                _item(Icons.person_outline, "Hisob ma'lumotlari".tr, () => Get.toNamed(Routes.ACCOUNT)),
                _item(Icons.settings_outlined, 'Ilova sozlamalari'.tr, () => Get.toNamed(Routes.SETTINGS)),
                _item(Icons.language, 'Til'.tr, showLanguageSheet, trailing: LocaleService.currentName),
                _item(Icons.download_outlined, 'Yuklanmalar'.tr, () => Get.toNamed(Routes.DOWNLOADS)),
              ]),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                child: Text('YORDAM'.tr,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, letterSpacing: 1.2)),
              ),
              _group([
                _item(Icons.help_outline, 'FAQ', () => Get.toNamed(Routes.FAQ)),
                _item(Icons.support_agent, "Qo'llab-quvvatlash".tr, _openSupport, trailing: 'Telegram'),
              ]),
              SizedBox(height: 28.h),

              SizedBox(
                height: 50.h,
                child: OutlinedButton(
                  onPressed: controller.isLoggingOut.value ? null : _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: controller.isLoggingOut.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
                        )
                      : Text('Tizimdan chiqish'.tr,
                          style: TextStyle(color: AppColors.danger, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text('${'Versiya'.tr} ${AppConfig.appVersion}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _subscriptionSection(MySubscriptionModel? sub) {
    final active = sub?.active ?? false;
    String date(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    final card = Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green.withValues(alpha: active ? 0.35 : 0.2), AppColors.surface],
        ),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(active ? 'Premium obuna faol'.tr : 'Premium obuna'.tr,
                    style: TextStyle(color: AppColors.greenLight, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                Text(
                  active && sub!.endDate != null
                      ? '@d kun qoldi • @date gacha'.trParams({'d': '${sub.daysLeft}', 'date': date(sub.endDate!)})
                      : "Barcha seriallarni cheklovsiz ko'ring".tr,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(active ? 'Uzaytirish'.tr : 'Ulanish'.tr,
                style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          ),
        ],
      ),
    );

    final purchased = sub?.series ?? const <SeriesAccessModel>[];
    return [
      card,
      if (purchased.isNotEmpty) ...[
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text('SOTIB OLINGAN SERIALLAR'.tr,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, letterSpacing: 1.2)),
        ),
        _group([
          for (final s in purchased)
            ListTile(
              onTap: () => openSeriesById(s.seriesId),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: AppNetworkImage(s.imagePath, width: 40.w, height: 56.h),
              ),
              title: Text(s.title, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              subtitle: s.endDate == null
                  ? null
                  : Text('@d kun qoldi • @date gacha'.trParams({'d': '${s.daysLeft}', 'date': date(s.endDate!)}),
                      style: TextStyle(
                          color: s.daysLeft <= 3 ? AppColors.danger : AppColors.textSecondary, fontSize: 11.sp)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ),
        ]),
      ],
    ];
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Tizimdan chiqish'.tr, style: const TextStyle(color: Colors.white)),
        content: Text('Haqiqatan ham chiqmoqchimisiz?'.tr, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Bekor qilish'.tr, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text('Chiqish'.tr, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _group(List<Widget> children) {
    // ListTile bosish effekti ko'rinishi uchun fon Material orqali beriladi.
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) Divider(height: 1, color: AppColors.border, indent: 52.w),
          ],
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap, {String? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 22.sp),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
