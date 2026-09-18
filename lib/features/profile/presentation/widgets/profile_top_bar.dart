import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileTopBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  const ProfileTopBar({super.key, this.onBack, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Text(
            'PROFIL',
            style: AppTextStyles.tabActive.copyWith(
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
          InkWell(
            onTap: onEdit,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
