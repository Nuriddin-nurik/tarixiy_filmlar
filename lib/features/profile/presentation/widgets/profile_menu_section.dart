import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/profile_menu_item.dart';

IconData _iconFor(ProfileMenuIconKind kind) {
  switch (kind) {
    case ProfileMenuIconKind.account:
      return Icons.person_outline_rounded;
    case ProfileMenuIconKind.settings:
      return Icons.settings_outlined;
    case ProfileMenuIconKind.devices:
      return Icons.devices_rounded;
    case ProfileMenuIconKind.help:
      return Icons.help_outline_rounded;
  }
}

class ProfileMenuSection extends StatelessWidget {
  final String? title;
  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem>? onItemTap;

  const ProfileMenuSection({
    super.key,
    required this.items,
    this.title,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                title!.toUpperCase(),
                style: AppTextStyles.episodeCardMeta.copyWith(
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  _MenuRow(
                    item: items[i],
                    showDivider: i != items.length - 1,
                    onTap: () => onItemTap?.call(items[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final ProfileMenuItem item;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_iconFor(item.icon), size: 20, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.episodeCardTitle),
                      const SizedBox(height: 2),
                      Text(item.subtitle, style: AppTextStyles.episodeCardMeta),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(height: 1, color: AppColors.border),
              ),
          ],
        ),
      ),
    );
  }
}
