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
import '../../main/views/main_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const _bg = Color(0xFF0B0C10);
  static const _soft = Color(0xFFC5C6C7);

  Future<void> _openSupport() async {
    final app = Uri.parse('tg://resolve?domain=${AppConfig.supportTelegram}');
    final web = Uri.parse('https://t.me/${AppConfig.supportTelegram}');
    if (!await launchUrl(app, mode: LaunchMode.externalApplication)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          Get.find<HomeController>().homeData.value;
          final user = controller.user;
          final name = (user?.username?.isNotEmpty ?? false) ? user!.username! : 'Mehmon'.tr;
          final initial = name.characters.first.toUpperCase();

          return ListView(
            padding: EdgeInsets.only(bottom: kFloatingNavSpace),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PROFIL'.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.cinzel,
                          color: AppColors.green,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          height: 28 / 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed(Routes.ACCOUNT),
                      icon: AppIcon('profile_edit', size: 20.w),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 64.w,
                          height: 64.w,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: -15.w,
                                top: -15.w,
                                child: SvgIcon('avatar_ring', width: 94.w, height: 94.w),
                              ),
                              Positioned(
                                left: 5.w,
                                top: 5.w,
                                child: Container(
                                  width: 54.w,
                                  height: 54.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.green.withValues(alpha: 0.15),
                                  ),
                                  child: Text(initial,
                                      style: TextStyle(
                                          color: AppColors.green, fontSize: 24.sp, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700, height: 28 / 18)),
                              if (user?.email != null)
                                Text(user!.email!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: _soft, fontSize: 14.sp, height: 20 / 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    ..._subscriptionSection(controller.subscription.value),
                    SizedBox(height: 32.h),

                    _menu([
                      _item('menu_user', "Hisob ma'lumotlari".tr, () => Get.toNamed(Routes.ACCOUNT)),
                      _item('menu_settings', 'Ilova sozlamalari'.tr, () => Get.toNamed(Routes.SETTINGS)),
                      _item('menu_globe', 'Til'.tr, showLanguageSheet, trailing: LocaleService.currentName),
                      _item('menu_download', 'Yuklanmalar'.tr, () => Get.toNamed(Routes.DOWNLOADS)),
                    ]),
                    SizedBox(height: 32.h),

                    Text('YORDAM'.tr,
                        style: TextStyle(
                            color: _soft, fontSize: 14.sp, fontWeight: FontWeight.w600, letterSpacing: 0.7, height: 20 / 14)),
                    SizedBox(height: 8.h),
                    _menu([
                      _item('menu_faq', 'FAQ', () => Get.toNamed(Routes.FAQ)),
                      _item('menu_support', "Qo'llab-quvvatlash".tr, _openSupport, trailing: 'Telegram'),
                    ]),
                    SizedBox(height: 48.h),

                    Material(
                      color: const Color(0xFF311111),
                      borderRadius: BorderRadius.circular(12.r),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: controller.isLoggingOut.value ? null : _confirmLogout,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: controller.isLoggingOut.value
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF87171)),
                                  )
                                : Text('Tizimdan chiqish'.tr,
                                    style: TextStyle(
                                        color: const Color(0xFFF87171),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Text('${'Versiya'.tr} ${AppConfig.appVersion}',
                          style: TextStyle(color: _soft.withValues(alpha: 0.5), fontSize: 12.sp, height: 16 / 12)),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
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
        color: const Color(0xFF0A1811),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppIcon('gem', size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(active ? 'Premium obuna faol'.tr : 'Premium obuna'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.green, fontSize: 18.sp, fontWeight: FontWeight.w700, height: 28 / 18)),
                Text(
                  active && sub!.endDate != null
                      ? '@kun kun qoldi • @sana gacha'.trParams({'kun': '${sub.daysLeft}', 'sana': date(sub.endDate!)})
                      : "Barcha seriallarni cheklovsiz ko'ring".tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _soft, fontSize: 12.sp, height: 16 / 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(8.r),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(active ? 'Uzaytirish'.tr : 'Ulanish'.tr,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700, height: 20 / 14)),
              ),
            ),
          ),
        ],
      ),
    );

    final purchased = sub?.series ?? const <SeriesAccessModel>[];
    return [
      card,
      if (purchased.isNotEmpty) ...[
        SizedBox(height: 24.h),
        Text('SOTIB OLINGAN SERIALLAR'.tr,
            style: TextStyle(color: _soft, fontSize: 14.sp, fontWeight: FontWeight.w600, letterSpacing: 0.7, height: 20 / 14)),
        SizedBox(height: 8.h),
        _menu([
          for (final s in purchased)
            InkWell(
              onTap: () => openSeriesById(s.seriesId),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: AppNetworkImage(s.imagePath, width: 40.w, height: 56.h),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500, height: 1.5)),
                          if (s.endDate != null)
                            Text(
                              '@kun kun qoldi • @sana gacha'.trParams({'kun': '${s.daysLeft}', 'sana': date(s.endDate!)}),
                              style: TextStyle(
                                  color: s.daysLeft <= 3 ? AppColors.danger : _soft, fontSize: 12.sp, height: 16 / 12),
                            ),
                        ],
                      ),
                    ),
                    AppIcon('menu_chevron', size: 14.w),
                  ],
                ),
              ),
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

  Widget _menu(List<Widget> children) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ],
        ],
      ),
    );
  }

  Widget _item(String icon, String title, VoidCallback onTap, {String? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            SizedBox(width: 24.w, height: 24.w, child: Center(child: AppIcon(icon, size: 20.w))),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500, height: 1.5)),
            ),
            if (trailing != null) ...[
              Text(trailing, style: TextStyle(color: _soft, fontSize: 12.sp)),
              SizedBox(width: 8.w),
            ],
            AppIcon('menu_chevron', size: 14.w),
          ],
        ),
      ),
    );
  }
}
