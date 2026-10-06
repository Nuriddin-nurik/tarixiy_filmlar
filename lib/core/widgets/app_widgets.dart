import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // Serial rasmlari katta (2-3 MB PNG) — ekrandagi o'lchamiga kichraytirib xotiraga ochamiz.
    // Aks holda har rasm to'liq o'lchamda dekodlanadi va ro'yxat varaqlanganda qotadi.
    return LayoutBuilder(builder: (context, constraints) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final w = width ?? (constraints.hasBoundedWidth ? constraints.maxWidth : null);
      final cacheWidth = w == null || w <= 0 ? null : (w * dpr).round();
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => Container(width: width, height: height, color: AppColors.surface),
        errorWidget: (_, __, ___) => fallback,
      );
    });
  }
}

/// Assets/icons dagi Figma SVG ikonkasi. [color] berilsa, ikonka shu rangga bo'yaladi.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 18, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// Bo'lim sarlavhasi (Figma: "Section header").
/// Oddiy ko'rinish: 18px qalin sarlavha + kichik oltin ikonka, ostida izoh, o'ngda "Barchasi ›".
/// [accentBar] — "Ko'rishni davom etish" uslubi: chapda qizil chiziq va 16px sarlavha.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.icon,
    this.accentBar = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  /// Sarlavha yonidagi kichik ikonka nomi (assets/icons), masalan 'crown_small' yoki 'gold_dot'.
  final String? icon;
  final bool accentBar;

  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (accentBar) ...[
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentBar ? AppColors.textPrimary : AppColors.textHeading,
              fontSize: (accentBar ? 16 : 18).sp,
              fontWeight: FontWeight.w700,
              letterSpacing: accentBar ? 0.4 : 0.45,
              height: accentBar ? 1.5 : 28 / 18,
            ),
          ),
        ),
        if (icon != null) ...[
          SizedBox(width: 8.w),
          AppIcon(icon!, size: icon == 'gold_dot' ? 6.w : 12.w),
        ],
      ],
    );

    return Padding(
      // Figma: bo'lim 16px + sarlavha 4px ichki chekinish.
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: accentBar ? CrossAxisAlignment.center : CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleRow,
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 16 / 12),
                  ),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSeeAll,
              child: accentBar
                  ? Padding(
                      padding: EdgeInsets.all(4.w),
                      child: AppIcon('chevron_right_12', size: 12.w),
                    )
                  : Row(
                      children: [
                        Text('Barchasi'.tr,
                            style: TextStyle(
                                color: AppColors.gold, fontSize: 12.sp, fontWeight: FontWeight.w600, height: 16 / 12)),
                        SizedBox(width: 4.w),
                        AppIcon('chevron_right', size: 10.w),
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

/// Kvadrat bo'lmagan Figma SVG (fon effektlari va h.k.), asl ranglari bilan.
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.name, {super.key, required this.width, required this.height});

  final String name;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/$name.svg', width: width, height: height, fit: BoxFit.fill);
}
