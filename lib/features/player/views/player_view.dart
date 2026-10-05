import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/episode_model.dart';
import '../controllers/player_controller.dart';
import '../controllers/download_controller.dart';
import '../widgets/download_button.dart';

class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final DownloadController downloadController = Get.find<DownloadController>();

    final video = MaterialVideoControlsTheme(
      normal: _controlsTheme(fullscreen: false),
      fullscreen: _controlsTheme(fullscreen: true),
      child: Video(controller: controller.videoController, controls: MaterialVideoControls),
    );

    // Telefon yon tomonga burilsa — faqat video, butun ekran bo'ylab
    // (aks holda pastdagi ro'yxat ekrandan chiqib ketadi).
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Scaffold(backgroundColor: Colors.black, body: video);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIDEO PLEYER
            AspectRatio(aspectRatio: 16 / 9, child: video),

            // 2. TAFSILOTLAR VA QISMLAR
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.green));
                }

                final current = controller.currentEpisode.value;
                final list = controller.visibleEpisodes;
                final seasons = controller.seasons;

                return ListView(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (current != null)
                            Text(
                              '@s-FASL • @e-QISM'.trParams({'s': '${current.seasonNumber ?? 1}', 'e': '${current.episodeNumber ?? ''}'}),
                              style: TextStyle(
                                color: AppColors.greenLight,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Text(
                            controller.seriesTitle.value.isNotEmpty
                                ? controller.seriesTitle.value
                                : (current?.title ?? ''),
                            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          if (current?.title != null && controller.seriesTitle.value.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(current!.title!,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Fasllar
                    if (seasons.length > 1) ...[
                      SizedBox(
                        height: 34.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: seasons.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (_, i) {
                            final s = seasons[i];
                            final selected = controller.selectedSeason.value == s;
                            return ChoiceChip(
                              label: Text('@s-fasl'.trParams({'s': '$s'})),
                              selected: selected,
                              onSelected: (_) => controller.selectedSeason.value = s,
                              showCheckmark: false,
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.green,
                              side: BorderSide(color: selected ? AppColors.green : AppColors.border),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Tablar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          _buildTab(0, 'Barcha qism'),
                          SizedBox(width: 20.w),
                          _buildTab(1, "Ko'rilganlar"),
                          SizedBox(width: 20.w),
                          _buildTab(2, 'Yuklanganlar'),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.border, height: 1.h),
                    SizedBox(height: 8.h),

                    if (list.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Text(
                          controller.currentTabIndex.value == 2
                              ? "Yuklangan qismlar yo'q"
                              : "Bu yerda hozircha qism yo'q",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                        ),
                      )
                    else
                      ...list
                          .where((e) => controller.currentTabIndex.value != 2 ||
                              downloadController.isComplete(e.id!))
                          .map((e) => _episodeTile(e, current?.id == e.id)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  MaterialVideoControlsThemeData _controlsTheme({required bool fullscreen}) {
    return MaterialVideoControlsThemeData(
      seekBarPositionColor: AppColors.green,
      seekBarThumbColor: AppColors.green,
      // Boshqaruvlar tez yashirinsa, media_kit seek bar'ni surish paytida o'chirib yuboradi
      // ("widget has been unmounted" xatosi). Shuning uchun yashirinish vaqtini uzaytiramiz.
      controlsHoverDuration: const Duration(seconds: 5),
      // Ekranning chap/o'ng tomoniga ikki marta bosish — 10 soniya orqaga/oldinga.
      seekOnDoubleTap: true,
      seekOnDoubleTapBackwardDuration: const Duration(seconds: 10),
      seekOnDoubleTapForwardDuration: const Duration(seconds: 10),
      topButtonBar: [
        if (!fullscreen)
          MaterialCustomButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            iconSize: 20,
            onPressed: Get.back,
          ),
        const Spacer(),
        MaterialCustomButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _showQualitySheet,
        ),
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        MaterialCustomButton(
          icon: const Icon(Icons.replay_10_rounded),
          iconSize: 36,
          onPressed: () => controller.seekBy(-10),
        ),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 52),
        const Spacer(),
        MaterialCustomButton(
          icon: const Icon(Icons.forward_10_rounded),
          iconSize: 36,
          onPressed: () => controller.seekBy(10),
        ),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: const [
        MaterialPositionIndicator(),
        Spacer(),
        MaterialFullscreenButton(),
      ],
    );
  }

  void _showQualitySheet() {
    Widget option(int height, String label, {String? hint}) {
      return Obx(() {
        final selected = controller.selectedQuality.value == height;
        return ListTile(
          onTap: () {
            Get.back();
            controller.changeQuality(height);
          },
          title: Text(label, style: TextStyle(color: Colors.white, fontSize: 15.sp)),
          subtitle: hint == null
              ? null
              : Text(hint, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
          trailing: selected ? const Icon(Icons.check_circle, color: AppColors.greenLight) : null,
        );
      });
    }

    final qualities = controller.qualities;
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Video sifati'.tr,
                  style: TextStyle(color: AppColors.gold, fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              if (qualities.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    "Bu video uchun sifat tanlab bo'lmaydi".tr,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                  ),
                )
              else ...[
                option(0, 'Avto'.tr, hint: "Internet tezligiga qarab avtomatik".tr),
                for (final q in qualities)
                  option(q.height, q.label, hint: q.height >= 720 ? 'HD' : null),
              ],
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
    );
  }

  Widget _episodeTile(EpisodeModel episode, bool isPlaying) {
    final watched = episode.watchedSeconds ?? 0;
    final total = episode.durationSeconds ?? 0;
    final progress = total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0;
    final size = episode.fileSizeMb;

    return InkWell(
      onTap: () => controller.playEpisode(episode),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isPlaying ? Border.all(color: AppColors.green) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 110.w,
                height: 62.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(episode.thumbnail),
                    Center(
                      child: Icon(
                        !episode.canWatch
                            ? Icons.lock_outline
                            : (isPlaying ? Icons.equalizer_rounded : Icons.play_circle_fill),
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 24.sp,
                      ),
                    ),
                    if (progress > 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: progress,
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
                    episode.title ?? '@n-qism'.trParams({'n': '${episode.episodeNumber}'}),
                    style: TextStyle(
                      color: isPlaying ? AppColors.greenLight : Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    [
                      if (total > 0) formatDuration(total),
                      if (size != null && size > 0)
                        size >= 1024 ? '${(size / 1024).toStringAsFixed(1)} GB' : '${size.round()} MB',
                    ].join(' • '),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            if (episode.canWatch && episode.videoUrl != 'offline')
              DownloadButton(
                episode: episode,
                seriesId: controller.currentSeriesId.value,
                seriesTitle: controller.seriesTitle.value,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = controller.currentTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.currentTabIndex.value = index,
      child: Column(
        children: [
          Text(
            title.tr,
            style: TextStyle(
              color: isSelected ? AppColors.greenLight : AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 2,
            width: 40.w,
            color: isSelected ? AppColors.green : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
