import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/home/controllers/home_controller.dart';
import '../constants/app_config.dart';
import 'app_widgets.dart';

const _tgBlue = Color(0xFF2AABEE);
const _tgDeep = Color(0xFF1C7FC0);

Future<void> openSupport({bool payment = false}) async {
  final id = Get.isRegistered<HomeController>() ? Get.find<HomeController>().homeData.value?.user?.id : null;
  final text = Uri.encodeComponent([
    payment ? "Assalomu alaykum! To'lov bo'yicha savolim bor.".tr : 'Assalomu alaykum!'.tr,
    if (id != null) 'ID: $id',
  ].join('\n'));
  final app = Uri.parse('tg://resolve?domain=${AppConfig.supportTelegram}&text=$text');
  final web = Uri.parse('https://t.me/${AppConfig.supportTelegram}?text=$text');
  try {
    if (await launchUrl(app, mode: LaunchMode.externalApplication)) return;
  } catch (_) {}
  try {
    await launchUrl(web, mode: LaunchMode.externalApplication);
  } catch (_) {
    appSnack('Xato'.tr, 'Telegram ochilmadi'.tr);
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2C44), Color(0xFF0B1722)],
          ),
          border: Border.all(color: _tgBlue.withValues(alpha: 0.45)),
          boxShadow: [BoxShadow(color: _tgBlue.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: InkWell(
          onTap: () => openSupport(payment: true),
          child: Stack(
            children: [
              Positioned(
                right: -18.w,
                top: -18.w,
                child: Icon(Icons.support_agent_rounded, size: 110.sp, color: _tgBlue.withValues(alpha: 0.07)),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [_tgBlue, _tgDeep]),
                            boxShadow: [BoxShadow(color: _tgBlue.withValues(alpha: 0.45), blurRadius: 14)],
                          ),
                          child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 26.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "To'lov bo'yicha savolingiz bormi?".tr,
                                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700, height: 1.3),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                "Telegram orqali adminga to'g'ridan-to'g'ri yozing".tr,
                                style: TextStyle(color: const Color(0xFFB9D7EC), fontSize: 12.sp, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: const LinearGradient(colors: [_tgBlue, _tgDeep]),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Adminga yozish".tr,
                            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '@${AppConfig.supportTelegram}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportLink extends StatelessWidget {
  const SupportLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: _tgBlue.withValues(alpha: 0.12),
        shape: StadiumBorder(side: BorderSide(color: _tgBlue.withValues(alpha: 0.5))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openSupport(payment: true),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.support_agent_rounded, color: _tgBlue, size: 18.sp),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    "To'lovda muammo? Adminga yozing".tr,
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, color: _tgBlue, size: 18.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
