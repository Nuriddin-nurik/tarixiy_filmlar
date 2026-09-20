import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/favorite_item.dart';

/// A poster-style card with its title/subtitle overlaid on a bottom gradient,
/// matching the streaming-app look used across the rest of the design.
class FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveTap;

  const FavoriteCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Poster(item: item),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE6000000)],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _RemoveButton(onTap: onRemoveTap),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.episodeCardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.episodeCardMetaAccent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _RemoveButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(
          Icons.favorite_rounded,
          size: 15,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final FavoriteItem item;

  const _Poster({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.imageAsset.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.primarySofter],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.theater_comedy_rounded,
          size: 32,
          color: AppColors.primaryBorderSoft,
        ),
      );
    }

    return Image.asset(item.imageAsset, fit: BoxFit.cover);
  }
}
