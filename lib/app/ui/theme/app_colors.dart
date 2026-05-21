import 'package:flutter/material.dart';

class AppColors {
  // Industrial Gradients
  static const Color backgroundStart = Color(0xFF0F2027);
  static const Color backgroundMiddle = Color(0xFF203A43);
  static const Color backgroundEnd = Color(0xFF2C5364);

  static const Color background = Color(0xFF121212); // Fallback solid background
  
  // Dark Glass Surface
  static const Color surface = Color(0xFF1E2A38); // Slightly bluer/industrial
  static const Color surfaceTransparent = Color(0x991E2A38); // Dark Glass

  // Neon Accents
  static const Color primary = Color(0xFF00E5FF); // Bright Neon Cyan
  static const Color secondary = Color(0xFFB388FF); // Soft Neon Purple
  static const Color critical = Color(0xFFFF1744); // Neon Red
  static const Color warning = Color(0xFFFFB300); // Amber
  static const Color success = Color(0xFF00E676); // Neon Green

  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFA0A0A0);
  
  static const Color mapDarkStyleBackground = Color(0xFF1A232E);

  static LinearGradient get industrialBackground => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundMiddle, backgroundEnd],
  );
}
