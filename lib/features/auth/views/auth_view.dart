import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80.h),
                
                // Logo
                Image.asset('assets/logo.png', width: 260.w, fit: BoxFit.contain),

                SizedBox(height: 32.h),

                // Sarlavha
                Text(
                  'XUSH KELIBSIZ'.tr,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Qisqacha matn
                Text(
                  'Sevimli tarixiy serial va durdona filmlaringizni yuqori sifatda tomosha qilish uchun hisobingizga kiring'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 50.h),
                
                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : () => controller.signInWithGoogle(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    // SVG ni Image.network ko'rsata olmaydi, shuning uchun PNG ishlatamiz.
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.green),
                          )
                        : CachedNetworkImage(
                            imageUrl: 'https://developers.google.com/identity/images/g-logo.png',
                            height: 20.h,
                            errorWidget: (_, __, ___) =>
                                Text('G', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          ),
                    label: Text(
                      'Google orqali davom etish'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  )),
                ),
                
                SizedBox(height: 40.h), // Spacer o'rniga aniq joy tashlandi
                
                // Shartlar
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp, height: 1.5),
                    children: [
                      TextSpan(text: 'Davom etish orqali siz bizning '.tr),
                      TextSpan(
                        text: 'Foydalanish shartlari'.tr,
                        style: TextStyle(color: AppColors.gold),
                      ),
                      TextSpan(text: ' va '.tr),
                      TextSpan(
                        text: 'Maxfiylik siyosatiga'.tr,
                        style: TextStyle(color: AppColors.gold),
                      ),
                      TextSpan(text: ' rozilik bildirasiz.'.tr),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
