import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user_profile.dart';

class PremiumCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onUpgradeTap;

  const PremiumCard({super.key, required this.user, this.onUpgradeTap});

  @override
  Widget build(BuildContext context) {
    if (!user.isPremium) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySofter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBorderSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Premium Obuna', style: AppTextStyles.actionLabel),
                  const SizedBox(height: 2),
                  Text(
                    "Keyingi to'lov: ${user.premiumRenewalLabel}",
                    style: AppTextStyles.episodeCardMeta,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onUpgradeTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Uzatish',
                  style: AppTextStyles.episodeCardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
