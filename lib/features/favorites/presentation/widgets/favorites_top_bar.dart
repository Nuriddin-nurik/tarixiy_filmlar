import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FavoritesTopBar extends StatelessWidget {
  final int count;

  const FavoritesTopBar({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primarySofter,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 16,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 10),
          Text('Sevimlilar', style: AppTextStyles.title.copyWith(fontSize: 20)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('$count ta', style: AppTextStyles.episodeCardMeta),
          ),
        ],
      ),
    );
  }
}
