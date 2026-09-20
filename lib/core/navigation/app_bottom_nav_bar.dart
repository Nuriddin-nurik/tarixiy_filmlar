import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_icon.dart';
import 'app_nav_tab.dart';

class AppBottomNavBar extends StatelessWidget {
  final AppNavTab current;
  final ValueChanged<AppNavTab>? onChanged;

  const AppBottomNavBar({super.key, required this.current, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 84,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: Color(0xF208090C),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: AppIcons.home,
                label: 'Bosh sahifa',
                isActive: current == AppNavTab.home,
                onTap: () => onChanged?.call(AppNavTab.home),
              ),
              _NavItem(
                icon: AppIcons.grid,
                label: 'Epizodlar',
                isActive: current == AppNavTab.episodes,
                onTap: () => onChanged?.call(AppNavTab.episodes),
              ),
              _NavItem(
                icon: AppIcons.heart,
                label: 'Sevimlilar',
                isActive: current == AppNavTab.favorites,
                onTap: () => onChanged?.call(AppNavTab.favorites),
              ),
              _NavItem(
                icon: AppIcons.user,
                label: 'Profil',
                isActive: current == AppNavTab.profile,
                onTap: () => onChanged?.call(AppNavTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryLight : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: isActive ? AppTextStyles.navLabelActive : AppTextStyles.navLabel,
          ),
        ],
      ),
    );
  }
}
