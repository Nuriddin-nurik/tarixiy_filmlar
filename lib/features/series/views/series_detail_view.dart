import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/series_details_model.dart';
import '../../subscription/widgets/purchase_sheet.dart';
import '../controllers/series_detail_controller.dart';

class SeriesDetailView extends GetView<SeriesDetailController> {
  const SeriesDetailView({super.key});

  void _openPlayer({int? episodeId}) {
    Get.toNamed(Routes.PLAYER, arguments: {
      'seriesId': controller.series.id,
      'episodeId': episodeId,
      'title': controller.series.title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final series = controller.series;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final details = controller.details.value;
        final parts = details?.parts ?? const <EpisodePartModel>[];

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 32.h),
              children: [
                // Poster
                SizedBox(
                  height: 420.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(series.imagePath),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, 0.5, 1],
                            colors: [Colors.black45, Colors.transparent, AppColors.background],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        bottom: 12.h,
                        child: Text(
                          (series.title ?? '').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            shadows: const [Shadow(blurRadius: 12, color: Colors.black)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        [
                          if (details != null) '@n fasl'.trParams({'n': '${details.seasonCount}'}),
                          if (parts.isNotEmpty) '@n qism'.trParams({'n': '${parts.length}'}),
                        ].join(' • '),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: series.genreNames.map(_chip).toList(),
                      ),
                      SizedBox(height: 20.h),

                      // Tomosha qilish
                      SizedBox(
                        height: 50.h,
                        child: ElevatedButton.icon(
                          onPressed: parts.isEmpty
                              ? null
                              : () => _openPlayer(episodeId: controller.resumeEpisodeId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            disabledBackgroundColor: AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          label: Text(
                            'Tomosha qilish'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Like va ko'rishlar
                      Row(
                        children: [
                          Expanded(
                            child: _StatButton(
                              icon: controller.liked.value ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                              label: formatCount(controller.likeCount.value),
                              active: controller.liked.value,
                              onTap: controller.toggleLike,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _StatButton(
                              icon: Icons.visibility_outlined,
                              label: formatCount(details?.viewCount ?? series.viewCount ?? 0),
                            ),
                          ),
                        ],
                      ),

                      if ((series.freeEpisodesCount ?? 0) > 0 && !(details?.hasAccess ?? false)) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.card_giftcard, color: AppColors.greenLight, size: 22.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'Dastlabki @n ta qism BEPUL'.trParams({'n': '${series.freeEpisodesCount}'}),
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (details != null && !details.hasAccess) ...[
                        SizedBox(height: 12.h),
                        Material(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            // Alohida narxi bo'lsa shu serialni sotib olish, bo'lmasa umumiy obuna sahifasi.
                            onTap: series.monthlyPrice != null || series.quarterlyPrice != null
                                ? () => showPurchaseSheet(
                                      seriesId: series.id,
                                      title: series.title ?? '',
                                      monthlyPrice: series.monthlyPrice,
                                      quarterlyPrice: series.quarterlyPrice,
                                    )
                                : () => Get.toNamed(Routes.SUBSCRIPTION),
                            child: Padding(
                              padding: EdgeInsets.all(14.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Barcha qismlarga kirish'.tr,
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                        Text(
                                            series.quarterlyPrice != null
                                                ? '3 oylik'.tr
                                                : series.monthlyPrice != null
                                                    ? '1 oylik'.tr
                                                    : "Obuna bo'lish".tr,
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
                                      ],
                                    ),
                                  ),
                                  if ((series.quarterlyPrice ?? series.monthlyPrice) != null)
                                    Text(
                                      formatSom((series.quarterlyPrice ?? series.monthlyPrice)!),
                                      style: TextStyle(
                                          color: AppColors.gold, fontSize: 15.sp, fontWeight: FontWeight.w700),
                                    ),
                                  Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),

                SectionHeader(title: 'Qismlar'.tr),
                SizedBox(height: 12.h),
                if (controller.isLoading.value)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.green)),
                  )
                else if (parts.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text("Hozircha qismlar yo'q".tr,
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
                  )
                else
                  ...parts.map((p) => _EpisodeTile(part: p, onTap: () => _openPlayer(episodeId: p.episodeId))),
              ],
            ),

            // Orqaga tugmasi
            Positioned(
              top: top + 8.h,
              left: 12.w,
              child: _CircleButton(icon: Icons.arrow_back_ios_new, onTap: Get.back),
            ),
          ],
        );
      }),
    );
  }

  Widget _chip(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
      );
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: Colors.white, size: 18.sp),
        ),
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({required this.icon, required this.label, this.onTap, this.active = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.greenLight : Colors.white;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 6.w),
              Text(label, style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
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
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    [
                      if (part.seasonNumber != null) '@s-fasl'.trParams({'s': '${part.seasonNumber}'}),
                      if (part.durationSeconds > 0) formatDuration(part.durationSeconds),
                      if (part.free && !part.hasAccess) 'Bepul'.tr,
                    ].join(' • '),
                    style: TextStyle(
                      color: part.free && !part.hasAccess ? AppColors.greenLight : AppColors.textSecondary,
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
