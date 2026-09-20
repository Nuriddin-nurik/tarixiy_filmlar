import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/series_detail.dart';

class VideoPlayerHeader extends StatelessWidget {
  final SeriesDetail series;
  final VoidCallback? onBack;

  const VideoPlayerHeader({super.key, required this.series, this.onBack});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(series.coverAsset, fit: BoxFit.cover),
          Container(color: AppColors.overlayDark),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: AppIcons.arrowLeft,
                      size: 32,
                      iconSize: 16,
                      onTap: onBack,
                    ),
                    Row(
                      children: const [
                        _CircleIconButton(
                          icon: AppIcons.cast,
                          size: 32,
                          iconSize: 16,
                        ),
                        SizedBox(width: 8),
                        _CircleIconButton(
                          icon: AppIcons.moreVertical,
                          size: 32,
                          iconSize: 16,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _CircleIconButton(
                      icon: AppIcons.rotateCcw,
                      size: 36,
                      iconSize: 18,
                      background: AppColors.scrim,
                    ),
                    SizedBox(width: 40),
                    _PlayButton(),
                    SizedBox(width: 40),
                    _CircleIconButton(
                      icon: AppIcons.rotateCw,
                      size: 36,
                      iconSize: 18,
                      background: AppColors.scrim,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Timeline(progress: series.progress),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatDuration(series.currentPosition),
                              style: AppTextStyles.timeCurrent,
                            ),
                            const SizedBox(width: 4),
                            Text('/', style: AppTextStyles.timeTotal),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(series.totalDuration),
                              style: AppTextStyles.timeTotal,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.primaryBorderSoft,
                                ),
                              ),
                              child: Text(
                                series.videoQualityLabel,
                                style: AppTextStyles.badgeFhd,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const AppIcon(AppIcons.maximize, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final double progress;

  const _Timeline({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const AppIcon(AppIcons.play, size: 24),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String icon;
  final double size;
  final double iconSize;
  final Color background;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    this.background = AppColors.overlayDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Center(child: AppIcon(icon, size: iconSize)),
      ),
    );
  }
}
