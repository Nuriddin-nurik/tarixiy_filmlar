import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user_profile.dart';

class ProfileUserCard extends StatelessWidget {
  final UserProfile user;

  const ProfileUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(child: _Avatar(user: user)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTextStyles.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final UserProfile user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.avatarAsset.isEmpty) {
      return Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.person_rounded,
          size: 32,
          color: AppColors.textMuted,
        ),
      );
    }

    return Image.asset(user.avatarAsset, fit: BoxFit.cover);
  }
}
