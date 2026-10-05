import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/series_details_model.dart';
import '../../subscription/widgets/purchase_sheet.dart';
import '../controllers/series_detail_controller.dart';

/// Serial sahifasi — Figma: "03 Serial tafsilotlari" (node 1:32).
/// Dizayndagi IMDb/KP reytingi, tavsif, yil, ulashish va menyu tugmalari qo'yilmagan:
/// backend bu ma'lumotlarni bermaydi.
class SeriesDetailView extends GetView<SeriesDetailController> {
  const SeriesDetailView({super.key});

  static const _font = AppFonts.jakarta;
  static const _green = AppColors.seriesGreen;

  void _openPlayer({int? episodeId}) {
    Get.toNamed(Routes.PLAYER, arguments: {
      'seriesId': controller.series.id,
      'episodeId': episodeId,
      'title': controller.series.title,
    });
  }

  TextStyle _t(double size, FontWeight w, Color c, {double? height, double? spacing}) => TextStyle(
        fontFamily: _font,
        fontSize: size.sp,
        fontWeight: w,
        color: c,
        height: height,
        letterSpacing: spacing,
      );

  @override
  Widget build(BuildContext context) {
    final series = controller.series;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.seriesBg,
      body: Obx(() {
        final details = controller.details.value;
        final parts = details?.parts ?? const <EpisodePartModel>[];
        final hasAccess = details?.hasAccess ?? false;
        final free = series.freeEpisodesCount ?? 0;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 32.h),
              children: [
                _Hero(imagePath: series.imagePath),
                // Figma: kontent rasm ustiga 56px chiqib turadi.
                Transform.translate(
                  offset: Offset(0, -56.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          (series.title ?? '').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.cinzel,
                            color: AppColors.seriesGold,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.65,
                            height: 32.5 / 26,
                            shadows: [
                              Shadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 10))
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (details != null)
                          Text(
                            '@s fasl (@n qism)'.trParams({'s': '${details.seasonCount}', 'n': '${parts.length}'}),
                            textAlign: TextAlign.center,
                            style: _t(12, FontWeight.w500, Colors.white.withValues(alpha: 0.6), height: 16 / 12, spacing: 0.3),
                          ),
                        SizedBox(height: 12.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: series.genreNames.map(_chip).toList(),
                        ),
                        SizedBox(height: 16.h),

                        // Figma: "Btn / Tomosha qilish".
                        _WatchButton(
                          enabled: parts.isNotEmpty,
                          label: 'Tomosha qilish'.tr,
                          onTap: () => _openPlayer(episodeId: controller.resumeEpisodeId),
                        ),
                        SizedBox(height: 12.h),

                        // Figma: "Stats" — layk va ko'rishlar.
                        Row(
                          children: [
                            Expanded(
                              child: _StatButton(
                                icon: 'like',
                                label: formatCount(controller.likeCount.value),
                                active: controller.liked.value,
                                onTap: controller.toggleLike,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _StatButton(
                                icon: 'eye',
                                label: formatCount(details?.viewCount ?? series.viewCount ?? 0),
                              ),
                            ),
                          ],
                        ),

                        if (free > 0 && !hasAccess) ...[
                          SizedBox(height: 16.h),
                          _freeCard(free),
                        ],

                        if (details != null && !hasAccess) ...[
                          SizedBox(height: 12.h),
                          _paidCard(free, parts.length),
                        ],
                      ],
                    ),
                  ),
                ),

                SectionHeader(title: 'Qismlar'.tr),
                SizedBox(height: 12.h),
                if (controller.isLoading.value)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: const Center(child: CircularProgressIndicator(color: _green)),
                  )
                else if (parts.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text("Hozircha qismlar yo'q".tr,
                        textAlign: TextAlign.center, style: _t(13, FontWeight.w400, AppColors.textSecondary)),
                  )
                else
                  ...parts.map((p) => _EpisodeTile(part: p, onTap: () => _openPlayer(episodeId: p.episodeId))),
              ],
            ),

            // Figma: "Btn / Orqaga" — 40px yumaloq, xira fon.
            Positioned(
              top: top + 8.h,
              left: 16.w,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: InkWell(
                      onTap: Get.back,
                      child: SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: Center(child: AppIcon('arrow_back', size: 16.w)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _chip(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(text, style: _t(12, FontWeight.w600, Colors.white.withValues(alpha: 0.8), height: 16 / 12)),
      );

  /// Figma: "Bepul qismlar" — chapda yashil chiziq.
  Widget _freeCard(int free) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161A1A).withValues(alpha: 0.7),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: _green),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: AppIcon('gift', size: 14.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Dastlabki @n ta qism BEPUL'.trParams({'n': '$free'}),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(12, FontWeight.w700, Colors.white, height: 16 / 12),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                AppIcon('live_dot', size: 8.w),
                              ],
                            ),
                            Text(
                              "Obunasiz to'liq tomosha qiling".tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10, FontWeight.w400, Colors.white.withValues(alpha: 0.6), height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('1–@n qism'.trParams({'n': '$free'}),
                            style: _t(11, FontWeight.w600, _green, height: 16 / 11)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Figma: "Pullik bo'limlar" — obuna va shu serialni sotib olish variantlari.
  Widget _paidCard(int free, int partCount) {
    final series = controller.series;
    // Obuna faqat obuna tarifidagi seriallarni ochadi — boshqa seriallarda bu variant ko'rsatilmaydi.
    final plan = series.subscriptionBased == true
        ? controller.plans.firstWhereOrNull((p) => p.monthlyPrice != null)
        : null;
    final seriesMonths = series.quarterlyPrice != null ? 3 : 1;
    final seriesPrice = series.quarterlyPrice ?? series.monthlyPrice;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF131716),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PULLIK BO'LIMLAR".tr,
                        style: _t(9, FontWeight.w700, AppColors.gold, height: 13.5 / 9, spacing: 0.9)),
                    Text("Barcha qismlarga to'liq kirish".tr,
                        style: _t(12, FontWeight.w700, Colors.white, height: 16 / 12)),
                  ],
                ),
              ),
              if (free > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text('@n-qismdan boshlab'.trParams({'n': '${free + 1}'}),
                      style: _t(10, FontWeight.w400, Colors.white.withValues(alpha: 0.5), height: 1.5)),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (plan != null) ...[
            _PriceOption(
              highlighted: true,
              title: plan.name,
              tag: '1 oy cheksiz'.tr,
              subtitle: 'Barcha seriallarga cheksiz kirish'.tr,
              price: plan.monthlyPrice!,
              per: 'oyiga'.tr,
              badge: 'ENG FOYDALI'.tr,
              onTap: () => showPurchaseSheet(
                planId: plan.id,
                title: plan.name,
                monthlyPrice: plan.monthlyPrice,
                quarterlyPrice: plan.quarterlyPrice,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (seriesPrice != null)
            _PriceOption(
              highlighted: plan == null,
              title: "Shu serial (to'liq)".tr,
              subtitle: '@n ta qism • @m oy'.trParams({'n': '$partCount', 'm': '$seriesMonths'}),
              price: seriesPrice,
              per: seriesMonths == 3 ? '3 oyga'.tr : 'oyiga'.tr,
              onTap: () => showPurchaseSheet(
                seriesId: series.id,
                title: series.title ?? '',
                monthlyPrice: series.monthlyPrice,
                quarterlyPrice: series.quarterlyPrice,
              ),
            ),
          if (plan == null && seriesPrice == null)
            _PriceOption(
              highlighted: true,
              title: "Obuna bo'lish".tr,
              subtitle: 'Barcha seriallarga cheksiz kirish'.tr,
              onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
            ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon('shield', size: 9.w),
              SizedBox(width: 6.w),
              Text("Pixy orqali xavfsiz to'lov".tr,
                  style: _t(10, FontWeight.w400, Colors.white.withValues(alpha: 0.4), height: 1.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 456.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(imagePath, fit: BoxFit.cover),
          // Figma: "Overlay" va "Overlay bottom".
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent, AppColors.seriesBg],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.6, 1],
                  colors: [
                    AppColors.seriesBg.withValues(alpha: 0),
                    AppColors.seriesBg.withValues(alpha: 0.8),
                    AppColors.seriesBg,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchButton extends StatelessWidget {
  const _WatchButton({required this.enabled, required this.label, required this.onTap});
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = AppColors.seriesGreen;
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: enabled ? [BoxShadow(color: green.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 4))] : null,
      ),
      child: Material(
        color: enabled ? green : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon('play', size: 14.w),
              SizedBox(width: 10.w),
              Text(label,
                  style: TextStyle(
                    fontFamily: AppFonts.jakarta,
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({required this.icon, required this.label, this.onTap, this.active = false});
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.seriesGreen : Colors.white.withValues(alpha: 0.8);
    return Material(
      color: active ? AppColors.seriesGreen.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: active ? AppColors.seriesGreen.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, size: 12.w, color: color),
              SizedBox(width: 8.w),
              Text(label,
                  style: TextStyle(
                    fontFamily: AppFonts.jakarta,
                    color: color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 16 / 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma: "Option / Oylik obuna" va "Option / Shu serial (To'liq)".
class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.highlighted,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tag,
    this.price,
    this.per,
    this.badge,
  });

  final bool highlighted;
  final String title;
  final String subtitle;
  final String? tag;
  final int? price;
  final String? per;
  final String? badge;
  final VoidCallback onTap;

  static String _digits(int n) {
    final d = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write(' ');
      b.write(d[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    const green = AppColors.seriesGreen;
    TextStyle t(double s, FontWeight w, Color c, [double? h]) =>
        TextStyle(fontFamily: AppFonts.jakarta, fontSize: s.sp, fontWeight: w, color: c, height: h);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: highlighted ? 0.04 : 0.02),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: highlighted ? green.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t(12, highlighted ? FontWeight.w700 : FontWeight.w600,
                                      Colors.white.withValues(alpha: highlighted ? 1 : 0.9), 16 / 12)),
                            ),
                            if (tag != null) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(tag!, style: t(9, FontWeight.w500, green, 13.5 / 9)),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t(10, FontWeight.w400, Colors.white.withValues(alpha: 0.5), 1.5)),
                      ],
                    ),
                  ),
                  if (price != null)
                    Container(
                      padding: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(_digits(price!), style: t(14, FontWeight.w800, Colors.white, 17.5 / 14)),
                              SizedBox(width: 3.w),
                              Text("so'm".tr, style: t(9, FontWeight.w400, Colors.white.withValues(alpha: 0.6), 1.5)),
                            ],
                          ),
                          if (per != null)
                            Text(per!, style: t(9, FontWeight.w400, Colors.white.withValues(alpha: 0.4), 1.5)),
                        ],
                      ),
                    )
                  else
                    Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4), size: 18.sp),
                ],
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 10.w,
            top: -9.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(4.r)),
              child: Text(badge!,
                  style: TextStyle(
                      fontFamily: AppFonts.jakarta,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                      height: 1.5)),
            ),
          ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.part, required this.onTap});
  final EpisodePartModel part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !part.hasAccess && !part.free;
    final progress = part.durationSeconds > 0 ? part.watchedSeconds / part.durationSeconds : 0.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 120.w,
                height: 68.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(part.thumbnail),
                    Center(
                      child: Icon(
                        locked ? Icons.lock_outline : Icons.play_circle_fill,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 26.sp,
                      ),
                    ),
                    if (progress > 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          color: AppColors.gold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.title ?? '@n-qism'.trParams({'n': '${part.episodeNumber}'}),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.jakarta, color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    [
                      if (part.seasonNumber != null) '@s-fasl'.trParams({'s': '${part.seasonNumber}'}),
                      if (part.durationSeconds > 0) formatDuration(part.durationSeconds),
                      if (part.free && !part.hasAccess) 'Bepul'.tr,
                    ].join(' • '),
                    style: TextStyle(
                      fontFamily: AppFonts.jakarta,
                      color: part.free && !part.hasAccess ? AppColors.seriesGreen : AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

