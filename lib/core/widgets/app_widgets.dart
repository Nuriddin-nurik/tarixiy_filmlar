import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../utils/image_url.dart';

/// Backend rasm yo'li ("/uploads/...") bilan ishlaydigan tarmoq rasmi.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(this.path, {super.key, this.width, this.height, this.fit = BoxFit.cover});

  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = fullImageUrl(path);
    final fallback = Container(
      width: width,
      height: height,
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 28.sp),
    );
    if (url == null) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(width: width, height: height, color: AppColors.surface),
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

/// Bo'lim sarlavhasi: chapda yashil chiziq + nom, ixtiyoriy izoh va "Barchasi >".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.onSeeAll});

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text('Barchasi'.tr, style: TextStyle(color: AppColors.gold, fontSize: 12.sp)),
                  Icon(Icons.chevron_right, color: AppColors.gold, size: 16.sp),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bo'sh holat (ma'lumot yo'q / tez kunda) uchun.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.gold, size: 36.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            if (message != null) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4),
              ),
            ],
            if (action != null) ...[SizedBox(height: 16.h), action!],
          ],
        ),
      ),
    );
  }
}

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '@h soat @m daq'.trParams({'h': '$h', 'm': '$m'});
  return '@m daq'.trParams({'m': '$m'});
}

/// 35000 -> "35 000 so'm"
String formatSom(int amount) {
  final digits = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return "@n so'm".trParams({'n': buf.toString()});
}

String formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

/// Qorong'i temaga mos xabar (Get.snackbar sukut bo'yicha qora matn bilan chiqadi).
void appSnack(String title, String message, {Duration? duration, Color? colorText, Color? backgroundColor}) {
  Get.snackbar(
    title,
    message,
    colorText: colorText ?? Colors.white,
    backgroundColor: backgroundColor ?? AppColors.surfaceLight.withValues(alpha: 0.95),
    borderColor: AppColors.border,
    borderWidth: 1,
    margin: EdgeInsets.all(12.w),
    duration: duration ?? const Duration(seconds: 3),
  );
}
