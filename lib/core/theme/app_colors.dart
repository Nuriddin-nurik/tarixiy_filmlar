import 'package:flutter/material.dart';

/// Figma dizaynidagi ranglar (fayl: "Tarixiy Kinolar").
class AppColors {
  static const background = Color(0xFF0B0D0E);
  static const surface = Color(0xFF141619);
  static const surfaceLight = Color(0xFF1E2226);
  static const border = Color(0xFF272A30);

  static const green = Color(0xFF00875A);
  static const greenLight = Color(0xFF00875A);
  static const gold = Color(0xFFD4AF37);
  static const goldDark = Color(0xFFB08D2C);

  // Serial sahifasidagi (Figma 03) ranglar — bu ekranda yashil va oltin biroz boshqacha.
  static const seriesGreen = Color(0xFF00A86B);
  static const seriesBg = Color(0xFF0C0F0E);
  static const seriesGold = Color(0xFFE6BF55);

  // Pleyer ekranidagi (Figma 04) ranglar.
  static const playerBg = Color(0xFF0B0C10);
  static const playerPanel = Color(0xFF101217);
  static const playerCard = Color(0xFF13151B);
  static const playerGreen = Color(0xFF0D7A57);
  static const playerAccent = Color(0xFF10B981);
  static const playerAccentText = Color(0xFF34D399);

  static const textPrimary = Colors.white;
  static const textHeading = Color(0xFFF3F4F6);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF6B7280);
  static const danger = Color(0xFFEF4444);
}

/// Figma'dagi shriftlar.
class AppFonts {
  static const inter = 'Inter';
  static const cinzel = 'Cinzel';
  static const jakarta = 'PlusJakartaSans'; // kirish va serial ekranlari
  static const notoSerif = 'NotoSerif'; // pleyer ekrani
}
