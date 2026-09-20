import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles matching the Inter weights used in the Figma design.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1,
    );
  }

  static TextStyle title = _inter(size: 18, weight: FontWeight.w700);
  static TextStyle subtitle = _inter(
    size: 13,
    weight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle episodeTag = _inter(
    size: 11,
    weight: FontWeight.w700,
    color: AppColors.primaryLight,
  );
  static TextStyle episodeMeta = _inter(
    size: 11,
    weight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle actionCount = _inter(size: 12, weight: FontWeight.w500);
  static TextStyle actionCountMuted = _inter(
    size: 12,
    weight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static TextStyle actionLabel = _inter(
    size: 12,
    weight: FontWeight.w600,
    color: AppColors.primaryLight,
  );

  static TextStyle tabActive = _inter(
    size: 13,
    weight: FontWeight.w700,
    color: AppColors.primaryLight,
  );
  static TextStyle tabInactive = _inter(
    size: 13,
    weight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static TextStyle tabBadge = _inter(
    size: 9,
    weight: FontWeight.w700,
    color: AppColors.primaryLight,
  );

  static TextStyle episodeCardTitle = _inter(
    size: 12,
    weight: FontWeight.w600,
  );
  static TextStyle episodeCardMetaAccent = _inter(
    size: 10,
    weight: FontWeight.w600,
    color: AppColors.primaryLight,
  );
  static TextStyle episodeCardMeta = _inter(
    size: 10,
    weight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  static TextStyle durationBadge = _inter(size: 8, weight: FontWeight.w500);

  static TextStyle navLabel = _inter(
    size: 10,
    weight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static TextStyle navLabelActive = _inter(
    size: 10,
    weight: FontWeight.w700,
    color: AppColors.primaryLight,
  );

  static TextStyle badgeFhd = _inter(
    size: 9,
    weight: FontWeight.w700,
    color: AppColors.primaryLight,
  );
  static TextStyle timeCurrent = _inter(
    size: 11,
    weight: FontWeight.w600,
    color: AppColors.primaryLight,
  );
  static TextStyle timeTotal = _inter(
    size: 11,
    weight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
