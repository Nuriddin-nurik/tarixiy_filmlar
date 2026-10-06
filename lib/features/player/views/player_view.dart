import 'dart:ui';

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

/// Pleyer — Figma: "04 Epizodlar" (node 2:227). Bu ekran Noto Serif shriftida.
/// Dizayndagi "Dublyaj", Cast tugmasi va layk/ko'rishlar soni qo'yilmagan: ma'lumoti yo'q.
class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  static TextStyle _t(double size, FontWeight w, Color c, {double? height, double? spacing}) => TextStyle(
        fontFamily: AppFonts.notoSerif,
        fontSize: size.sp,
        fontWeight: w,
        color: c,
        height: height,
        letterSpacing: spacing,
      );

  static const _muted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final DownloadController downloadController = Get.find<DownloadController>();

    final video = MaterialVideoControlsTheme(
      normal: _controlsTheme(fullscreen: false),
      fullscreen: _controlsTheme(fullscreen: true),
      child: Video(
        controller: controller.videoController,
        controls: MaterialVideoControls,
        onEnterFullscreen: PlayerController.enterFullscreen,
        onExitFullscreen: PlayerController.exitFullscreen,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.playerBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIDEO PLEYER (16:9)
            AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: video)),

            // 2. TAFSILOTLAR VA QISMLAR
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.playerAccent));
                }

                final current = controller.currentEpisode.value;
                final list = controller.visibleEpisodes
                    .where((e) => controller.currentTabIndex.value != 2 || downloadController.isComplete(e.id!))
                    .toList();
                final seasons = controller.seasons;

                return ListView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  children: [
                    // Figma: "Meta" paneli.
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.playerPanel,
                        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (current != null)
                            Text(
                              '@s-FASL • @e-QISM'.trParams(
                                  {'s': '${current.seasonNumber ?? 1}', 'e': '${current.episodeNumber ?? ''}'}),
                              style: _t(11, FontWeight.w700, AppColors.playerAccentText, height: 1.5, spacing: 0.55),
                            ),
                          SizedBox(height: 2.h),
                          Text(
                            controller.seriesTitle.value.isNotEmpty
                                ? controller.seriesTitle.value
                                : (current?.title ?? ''),
                            style: _t(16, FontWeight.w700, Colors.white, height: 22 / 16),
                          ),
                          if (current?.title != null && controller.seriesTitle.value.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(current!.title!, style: _t(12, FontWeight.w400, _muted, height: 16 / 12)),
                          ],

                          // Figma: "Quick actions" — joriy qismni yuklab olish.
                          if (current != null && current.canWatch && current.videoUrl != 'offline') ...[
                            SizedBox(height: 14.h),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                    horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                              ),
                              child: DownloadButton(
                                episode: current,
                                seriesId: controller.currentSeriesId.value,
                                seriesTitle: controller.seriesTitle.value,
                                wide: true,
                              ),
                            ),
                          ],

                          // Figma: "Season selector".
                          if (seasons.length > 1) ...[
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                    child: Text('Faslni tanlang:'.tr,
                                        style: _t(12, FontWeight.w500, _muted, height: 16 / 12))),
                                if (current != null)
                                  Text('@s-fasl (Hozirgi)'.trParams({'s': '${current.seasonNumber ?? 1}'}),
                                      style: _t(11, FontWeight.w500, AppColors.playerAccentText, height: 1.5)),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            SizedBox(
                              height: 36.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                itemCount: seasons.length,
                                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                                itemBuilder: (_, i) => _seasonChip(seasons[i]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Figma: "Tabs".
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.playerBg.withValues(alpha: 0.95),
                        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      ),
                      child: Row(
                        children: [
                          _buildTab(0, 'Barcha qism', count: controller.visibleEpisodesCount),
                          _buildTab(1, "Ko'rilganlar"),
                          _buildTab(2, 'Yuklanganlar'),
                        ],
                      ),
                    ),

                    // Figma: "EpisodeList".
                    if (list.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Text(
                          controller.currentTabIndex.value == 2
                              ? "Yuklangan qismlar yo'q".tr
                              : "Bu yerda hozircha qism yo'q".tr,
                          textAlign: TextAlign.center,
                          style: _t(13, FontWeight.w400, _muted),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            for (final e in list) ...[
                              _episodeTile(e, current?.id == e.id),
                              SizedBox(height: 12.h),
                            ],
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seasonChip(int s) {
    final selected = controller.selectedSeason.value == s;
    return GestureDetector(
      onTap: () => controller.selectedSeason.value = s,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: selected ? 16.w : 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.playerGreen : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF064E3B).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('@s-fasl'.trParams({'s': '$s'}),
                style: _t(12, selected ? FontWeight.w700 : FontWeight.w500, selected ? Colors.white : _muted,
                    height: 16 / 12)),
            if (selected) ...[SizedBox(width: 4.w), AppIcon('season_check', size: 12.w)],
          ],
        ),
      ),
    );
  }

  /// Figma: video ustidagi boshqaruvlar (yumaloq tugmalar, yashil "Ijro" tugmasi, 6px progress).
  MaterialVideoControlsThemeData _controlsTheme({required bool fullscreen}) {
    Widget circle(double size, Color color, Widget child, {Border? border, List<BoxShadow>? shadow}) => ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: border, boxShadow: shadow),
              child: child,
            ),
          ),
        );

    Widget seekIcon(String icon) => circle(
          40,
          Colors.black.withValues(alpha: 0.5),
          Stack(
            alignment: Alignment.center,
            children: [
              AppIcon(icon, size: 22),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text('10', style: TextStyle(fontFamily: AppFonts.notoSerif, fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25)),
              ),
            ],
          ),
        );

    return MaterialVideoControlsThemeData(
      // Vaqt chizig'i aniq ko'rinsin: qalinroq chiziq, ochroq fon va katta tutqich
      // (Figma: 6px, #10B981 to'ldirish).
      seekBarHeight: 5,
      seekBarContainerHeight: 40,
      seekBarColor: Colors.white.withValues(alpha: 0.35),
      seekBarBufferColor: Colors.white.withValues(alpha: 0.55),
      seekBarPositionColor: AppColors.playerAccent,
      seekBarThumbColor: Colors.white,
      seekBarThumbSize: 14,
      seekBarMargin: const EdgeInsets.symmetric(horizontal: 14),
      // Boshqaruvlar tez yashirinsa, media_kit seek bar'ni surish paytida o'chirib yuboradi
      // ("widget has been unmounted" xatosi). Shuning uchun yashirinish vaqtini uzaytiramiz.
      controlsHoverDuration: const Duration(seconds: 5),
      // Ekranning chap/o'ng tomoniga ikki marta bosish — 10 soniya orqaga/oldinga.
      seekOnDoubleTap: true,
      seekOnDoubleTapBackwardDuration: const Duration(seconds: 10),
      seekOnDoubleTapForwardDuration: const Duration(seconds: 10),
      topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 14),
      topButtonBar: [
        if (!fullscreen)
          MaterialCustomButton(
            icon: circle(36, Colors.black.withValues(alpha: 0.4), const AppIcon('player_back', size: 20)),
            iconSize: 36,
            onPressed: Get.back,
          ),
        const Spacer(),
        MaterialCustomButton(
          icon: circle(36, Colors.black.withValues(alpha: 0.4), const AppIcon('player_more', size: 18)),
          iconSize: 36,
          onPressed: _showQualitySheet,
        ),
      ],
      primaryButtonBar: [
        const Spacer(),
        MaterialCustomButton(
          icon: seekIcon('player_rewind'),
          iconSize: 40,
          onPressed: () => controller.seekBy(-10),
        ),
        const SizedBox(width: 32),
        // Figma: "Btn / Ijro" — 56px yashil doira.
        _PlayPauseButton(player: controller),
        const SizedBox(width: 32),
        MaterialCustomButton(
          icon: seekIcon('player_forward'),
          iconSize: 40,
          onPressed: () => controller.seekBy(10),
        ),
        const Spacer(),
      ],
      bottomButtonBarMargin: const EdgeInsets.only(left: 16, right: 8),
      bottomButtonBar: [
        MaterialPositionIndicator(
          style: TextStyle(fontFamily: AppFonts.notoSerif, fontSize: 11, color: const Color(0xFFD1D5DB), height: 1.5),
        ),
        const Spacer(),
        // Figma: "Badge / 1080p" — hozirgi sifat.
        Obx(() {
          final h = controller.playingHeight.value;
          if (h == 0) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.playerAccent.withValues(alpha: 0.3),
              border: Border.all(color: AppColors.playerAccent.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${h}P',
                style: TextStyle(
                    fontFamily: AppFonts.notoSerif,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.playerAccentText,
                    letterSpacing: 0.45,
                    height: 1.5)),
          );
        }),
        const MaterialFullscreenButton(icon: AppIcon('player_fullscreen', size: 16)),
      ],
    );
  }

  /// Sifat tanlash oynasi. O'lchamlar qat'iy (sp/h emas) — to'liq ekranda (gorizontal)
  /// ScreenUtil o'lchamlari kattalashib, oyna butun ekranni egallab qolardi.
  /// Gorizontal rejimda ekran markazida ixcham oyna, vertikalda pastdan chiqadi.
  void _showQualitySheet() {
    TextStyle st(double size, FontWeight w, Color c) =>
        TextStyle(fontFamily: AppFonts.notoSerif, fontSize: size, fontWeight: w, color: c, height: 1.3);

    Widget option(int height, String label, {String? hint}) {
      return Obx(() {
        final selected = controller.selectedQuality.value == height;
        // Avto rejimda hozir qaysi sifat ishlayotganini ham ko'rsatamiz: "Avto (480p)".
        final playing = controller.playingHeight.value;
        final title = height == 0 && selected && playing > 0 ? '$label (${playing}p)' : label;
        return InkWell(
          onTap: () {
            Get.back();
            controller.changeQuality(height);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: st(14, FontWeight.w500, Colors.white)),
                      if (hint != null) Text(hint, style: st(11, FontWeight.w400, _muted)),
                    ],
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, color: AppColors.playerAccentText, size: 20),
              ],
            ),
          ),
        );
      });
    }

    final qualities = controller.qualities;
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Video sifati'.tr, style: st(15, FontWeight.w700, AppColors.gold)),
          const SizedBox(height: 6),
          if (qualities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Bu video uchun sifat tanlab bo'lmaydi".tr, style: st(13, FontWeight.w400, _muted)),
            )
          else ...[
            option(0, 'Avto'.tr, hint: "Internet tezligiga qarab avtomatik".tr),
            for (final q in qualities) option(q.height, q.label, hint: q.height >= 720 ? 'HD' : null),
          ],
        ],
      ),
    );

    final landscape = MediaQuery.of(Get.context!).orientation == Orientation.landscape;
    if (landscape) {
      Get.dialog(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 320),
            child: Material(
              color: AppColors.playerCard,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: content,
            ),
          ),
        ),
      );
    } else {
      Get.bottomSheet(
        SafeArea(child: content),
        backgroundColor: AppColors.playerCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      );
    }
  }

  /// Figma: "Episode / ..." kartochkasi.
  Widget _episodeTile(EpisodeModel episode, bool isPlaying) {
    final watched = episode.watchedSeconds ?? 0;
    final total = episode.durationSeconds ?? 0;
    final progress = total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0;
    final size = episode.fileSizeMb;

    return Material(
      color: AppColors.playerCard,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isPlaying ? AppColors.playerGreen : Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => controller.playEpisode(episode),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Container(
                width: 112.w,
                height: 68.h,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(episode.thumbnail),
                    ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
                    // Figma: "Play bg" + o'yin ikonkasi (yopiq qismda qulf).
                    Center(
                      child: episode.canWatch
                          ? Stack(alignment: Alignment.center, children: [
                              AppIcon('ep_play_bg', size: 24.w),
                              AppIcon('ep_play', size: 14.w),
                            ])
                          : Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.9), size: 20.sp),
                    ),
                    if (total > 0)
                      Positioned(
                        right: 4.w,
                        bottom: progress > 0 ? 7.h : 4.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(_clock(total), style: _t(10, FontWeight.w500, const Color(0xFFD1D5DB), height: 1.5)),
                        ),
                      ),
                    if (progress > 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          color: AppColors.playerAccent,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title ?? '@n-qism'.trParams({'n': '${episode.episodeNumber}'}),
                      style: _t(12, FontWeight.w600,
                          isPlaying ? AppColors.playerAccentText : const Color(0xFFF3F4F6), height: 16.5 / 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text('@n-qism'.trParams({'n': '${episode.episodeNumber ?? ''}'}),
                            style: _t(11, FontWeight.w500, AppColors.playerAccentText, height: 1.5)),
                        if (size != null && size > 0) ...[
                          Text('  •  ', style: _t(11, FontWeight.w400, _muted)),
                          Text(size >= 1024 ? '${(size / 1024).toStringAsFixed(1)} GB' : '${size.round()} MB',
                              style: _t(11, FontWeight.w400, _muted, height: 1.5)),
                        ],
                      ],
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
      ),
    );
  }

  static String _clock(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  Widget _buildTab(int index, String title, {int? count}) {
    final isSelected = controller.currentTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.currentTabIndex.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: isSelected ? AppColors.playerAccent : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12, isSelected ? FontWeight.w700 : FontWeight.w500,
                      isSelected ? AppColors.playerAccentText : _muted,
                      height: 16 / 12),
                ),
              ),
              if (isSelected && count != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.playerAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count', style: _t(10, FontWeight.w400, AppColors.playerAccentText, height: 1.5)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma: "Btn / Ijro" — 56px yashil doira, 4px och yashil hoshiya.
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.player});
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: player.player.stream.playing,
      initialData: player.player.state.playing,
      builder: (_, snap) {
        final playing = snap.data ?? false;
        return GestureDetector(
          onTap: player.player.playOrPause,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.playerGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.playerAccent.withValues(alpha: 0.2), width: 4),
              boxShadow: [
                BoxShadow(color: const Color(0xFF022C22).withValues(alpha: 0.6), blurRadius: 15, offset: const Offset(0, 10))
              ],
            ),
            alignment: Alignment.center,
            child: playing
                ? const Icon(Icons.pause_rounded, color: Colors.white, size: 28)
                : const AppIcon('player_play', size: 28),
          ),
        );
      },
    );
  }
}
