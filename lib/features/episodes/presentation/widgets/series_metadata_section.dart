import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/series_detail.dart';

class SeriesMetadataSection extends StatelessWidget {
  final SeriesDetail series;
  final VoidCallback? onLike;
  final VoidCallback? onDownload;

  const SeriesMetadataSection({
    super.key,
    required this.series,
    this.onLike,
    this.onDownload,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                series.seasonLabel.toUpperCase(),
                style: AppTextStyles.episodeTag,
              ),
              const SizedBox(width: 6),
              Text('•', style: AppTextStyles.episodeMeta),
              const SizedBox(width: 6),
              Text(series.audioType, style: AppTextStyles.episodeMeta),
            ],
          ),
          const SizedBox(height: 8),
          Text(series.title, style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text(
            series.currentEpisodeTitle,
            style: AppTextStyles.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  icon: AppIcons.thumbsUp,
                  label: _formatCount(series.likeCount),
                  onTap: onLike,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  icon: AppIcons.eye,
                  label: _formatCount(series.viewCount),
                  muted: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  icon: AppIcons.download,
                  label: 'Yuklab olish',
                  highlighted: true,
                  onTap: onDownload,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool muted;
  final bool highlighted;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.muted = false,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = highlighted
        ? AppColors.primaryLight
        : (muted ? AppColors.textMuted : Colors.white);
    final textStyle = highlighted
        ? AppTextStyles.actionLabel
        : (muted ? AppTextStyles.actionCountMuted : AppTextStyles.actionCount);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.primarySofter : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlighted ? AppColors.primarySoft : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
