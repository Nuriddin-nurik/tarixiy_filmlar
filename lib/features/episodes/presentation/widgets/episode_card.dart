import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/episode.dart';

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final VoidCallback? onDownloadTap;

  const EpisodeCard({
    super.key,
    required this.episode,
    this.onTap,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = episode.downloadStatus == EpisodeDownloadStatus.locked;

    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: episode.isActive
                  ? AppColors.primaryBorderSoft
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              _Thumbnail(episode: episode),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title,
                      style: AppTextStyles.episodeCardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          episode.quality,
                          style: AppTextStyles.episodeCardMetaAccent,
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: AppTextStyles.episodeCardMeta),
                        const SizedBox(width: 6),
                        Text(
                          episode.sizeLabel,
                          style: AppTextStyles.episodeCardMeta,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!locked) _DownloadButton(episode: episode, onTap: onDownloadTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Episode episode;

  const _Thumbnail({required this.episode});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 96,
        height: 60,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(episode.thumbnailAsset, fit: BoxFit.cover),
            if (episode.isActive)
              Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.scrim,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(AppIcons.playSmall, size: 10),
                ),
              ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.overlayDarker,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  episode.duration,
                  style: AppTextStyles.durationBadge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;

  const _DownloadButton({required this.episode, this.onTap});

  @override
  Widget build(BuildContext context) {
    final downloaded = episode.downloadStatus == EpisodeDownloadStatus.downloaded;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: downloaded ? AppColors.primarySofter : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: downloaded
              ? Border.all(color: AppColors.primary)
              : null,
        ),
        child: AppIcon(
          downloaded ? AppIcons.check : AppIcons.downloadOutline,
          size: 14,
          color: downloaded ? AppColors.primaryLight : Colors.white,
        ),
      ),
    );
  }
}
