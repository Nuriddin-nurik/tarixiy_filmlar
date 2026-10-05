import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';

/// Kirish ekrani — Figma: "01 Kirish" (node 1:2).
/// Dizayndagi "Orqaga", "O'tkazib yuborish" va Apple tugmalari ataylab qo'yilmagan
/// (backend login'siz ishlamaydi, Apple orqali kirish hali yo'q).
class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  static const _jakarta = AppFonts.jakarta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Figma: fon gradienti #07090C → #0C1017 → #07090C.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07090C), Color(0xFF0C1017), Color(0xFF07090C)],
          ),
        ),
        child: Stack(
          children: [
            // Figma: "Emerald glow" (tepada) va "Gold glow" (pastki o'ng burchakda).
            Positioned(
              left: -65.w,
              top: -150.h,
              child: SvgIcon('login_glow_emerald', width: 520.w, height: 300.h),
            ),
            Positioned(
              left: 210.w,
              bottom: -180.h,
              child: SvgIcon('login_glow_gold', width: 360.w, height: 360.w),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    // Figma: "Logo" 280×112, soya bilan.
                    Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 24, offset: const Offset(0, 12)),
                      ]),
                      child: Image.asset('assets/logo.png', width: 280.w, height: 112.h, fit: BoxFit.contain),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Xush kelibsiz'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.cinzel,
                        color: const Color(0xFFF8FAFC),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        height: 32 / 24,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: 320.w,
                      child: Text(
                        'Sevimli tarixiy serial va durdona filmlaringizni yuqori sifatda tomosha qilish uchun hisobingizga kiring'
                            .tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _jakarta,
                          color: const Color(0xFF94A3B8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w300,
                          height: 19.5 / 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 56.h),

                    // Figma: "Btn / Google" — 48px, burchak 12.
                    Obx(() => Material(
                          color: const Color(0xFF161B24).withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: const Color(0xFF334155).withValues(alpha: 0.8)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: controller.isLoading.value ? null : controller.signInWithGoogle,
                            child: SizedBox(
                              height: 48.h,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.isLoading.value)
                                    SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.green),
                                    )
                                  else
                                    AppIcon('google', size: 16.w),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Google orqali davom etish'.tr,
                                    style: TextStyle(
                                      fontFamily: _jakarta,
                                      color: const Color(0xFFF1F5F9),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 20 / 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),

                    const Spacer(),

                    // Figma: "Footer" — shartlar.
                    SizedBox(
                      width: 320.w,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: _jakarta,
                            color: const Color(0xFF64748B),
                            fontSize: 11.sp,
                            height: 16.5 / 11,
                          ),
                          children: [
                            TextSpan(text: 'Davom etish orqali siz bizning '.tr),
                            TextSpan(
                              text: 'Foydalanish shartlari'.tr,
                              style: const TextStyle(color: Color(0xFFE0B25B), fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: ' va '.tr),
                            TextSpan(
                              text: 'Maxfiylik siyosatiga'.tr,
                              style: const TextStyle(color: Color(0xFFE0B25B), fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: ' rozilik bildirasiz.'.tr),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
