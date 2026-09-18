import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LogoutButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x33EF4444),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x66EF4444)),
          ),
          child: Text(
            'Tizimdan chiqish',
            style: AppTextStyles.episodeCardTitle.copyWith(
              color: const Color(0xFFF87171),
            ),
          ),
        ),
      ),
    );
  }
}
