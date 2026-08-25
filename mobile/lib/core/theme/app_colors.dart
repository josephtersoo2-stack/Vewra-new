import 'package:flutter/material.dart';

/// Centralized color palette for VEWRA application.
/// Provides a modern, premium dark-themed design system.
class AppColors {
  AppColors._();

  // Background & Surface
  static const Color background = Color(0xFF0D0F17);
  static const Color backgroundSecondary = Color(0xFF131722);
  static const Color surface = Color(0xFF1A1F2C);
  static const Color surfaceElevated = Color(0xFF22283A);
  static const Color surfaceLight = Color(0xFF2D344B);
  static const Color card = Color(0xFF1E2333);

  // Brand Accents
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color cyan = Color(0xFF06B6D4);

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color emerald = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B); // Amber / Gold (Coins)
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color amber = Color(0xFFFFB800);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF4B5563);

  // Borders & Dividers
  static const Color border = Color(0xFF283046);
  static const Color borderLight = Color(0xFF374151);
  static const Color divider = Color(0xFF1F2937);

  // Specialized & Reward
  static const Color coinGold = Color(0xFFFFB800);
  static const Color coinGoldDark = Color(0xFFD97706);
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color overlayDark = Color(0xCC0D0F17);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rewardGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2333), Color(0xFF161A26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
