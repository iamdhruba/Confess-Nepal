import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Vibrant Pink (Requested)
  static const Color primary = Color(0xFFFF4D94);
  static const Color primaryLight = Color(0xFFFF85B8);
  static const Color primaryDark = Color(0xFFD42D75);

  // Accent - Signature yellow for highlights (Stitch style)
  static const Color accent = Color(0xFFFFD93D);
  static const Color accentLight = Color(0xFFFFE57F);

  // Background layers (Dark Mode)
  static const Color backgroundDeep = Color(0xFF0E0E0E);
  static const Color backgroundPrimary = Color(0xFF131313);
  static const Color backgroundSecondary = Color(0xFF191A1A);
  static const Color backgroundCard = Color(0xFF1F2020);
  static const Color backgroundElevated = Color(0xFF262626);
  static const Color backgroundGlass = Color(0x1AFFFFFF);

  // Background layers (Light Mode)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFBFBFB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF5F5F7);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Text (Dark Mode)
  static const Color textPrimary = Color(0xFFE7E5E4);
  static const Color textSecondary = Color(0xFFACABAA);
  static const Color textTertiary = Color(0xFF767575);
  static const Color textMuted = Color(0xFF484848);

  // Text (Light Mode)
  static const Color textPrimaryLight = Color(0xFF121212);
  static const Color textSecondaryLight = Color(0xFF4B4B4B);
  static const Color textTertiaryLight = Color(0xFF717171);

  // Mood colors
  static const Color moodSad = Color(0xFF5B8DEF);
  static const Color moodLove = Color(0xFFFF4D94);
  static const Color moodFunny = Color(0xFFFFD93D);
  static const Color moodDark = Color(0xFF8B5CF6);
  static const Color moodConfused = Color(0xFFFF9F43);

  // Reaction colors
  static const Color reactionRelatable = Color(0xFF5B8DEF);
  static const Color reactionStayStrong = Color(0xFFFF6B8A);
  static const Color reactionWtf = Color(0xFFFF9F43);
  static const Color reactionFunny = Color(0xFFFFD93D);

  // Status colors
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4D94), Color(0xFFFFD93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF252536)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient moodGradient(String mood) {
    switch (mood) {
      case 'sad':
        return const LinearGradient(
          colors: [Color(0xFF1A2A4A), Color(0xFF2A3A5A)],
        );
      case 'love':
        return const LinearGradient(
          colors: [Color(0xFF3A1A2A), Color(0xFF4A2A3A)],
        );
      case 'funny':
        return const LinearGradient(
          colors: [Color(0xFF3A3A1A), Color(0xFF4A4A2A)],
        );
      case 'dark':
        return const LinearGradient(
          colors: [Color(0xFF2A1A3A), Color(0xFF3A2A4A)],
        );
      case 'confused':
        return const LinearGradient(
          colors: [Color(0xFF3A2A1A), Color(0xFF4A3A2A)],
        );
      default:
        return cardGradient;
    }
  }

  static Color moodColor(String mood) {
    switch (mood) {
      case 'sad':
        return moodSad;
      case 'love':
        return moodLove;
      case 'funny':
        return moodFunny;
      case 'dark':
        return moodDark;
      case 'confused':
        return moodConfused;
      default:
        return primary;
    }
  }

  static String moodEmoji(String mood) {
    switch (mood) {
      case 'sad':
        return '😢';
      case 'love':
        return '💕';
      case 'funny':
        return '😂';
      case 'dark':
        return '🌑';
      case 'confused':
        return '🤔';
      default:
        return '💭';
    }
  }
}
