import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Palette (Organic/Sage Agronomy Colors)
  static const Color primary = Color(0xFF386A20); // Deep organic forest green
  static const Color primaryLight = Color(0xFF649B4F); // Mid sage green
  static const Color primaryDark = Color(0xFF0F3C00); // Dark forest green
  
  static const Color secondary = Color(0xFFE2A014); // Harvest Amber
  static const Color secondaryLight = Color(0xFFFFD15C);
  static const Color secondaryDark = Color(0xFF9E6400);

  static const Color background = Color(0xFFEAF6F4); // Cool mint-teal wash light background
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Backdrop decoration (half-circle + accent circles behind every screen)
  static const Color backdropCirclePrimary = Color(0xFFBFE9E0); // big soft mint half-circle
  static const Color backdropCircleSecondary = Color(0xFF8FD4C7); // secondary teal blob
  static const Color backdropCircleAccent = Color(0xFF3FA79A); // small deep-teal accent dot
  
  // Status Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF386A20);
  static const Color warning = Color(0xFFE2A014);
  static const Color info = Color(0xFF0061A4);

  // Text and Boundaries
  static const Color textPrimary = Color(0xFF191E18); // Dark charcoal-green for high readability
  static const Color textSecondary = Color(0xFF43493E); // Soft muted sage gray
  static const Color border = Color(0xFFD2D8CD); // Sage grey border
  static const Color divider = Color(0xFFE2E8DC);

  // Glassmorphic / Premium layout colors
  static const Color glassCardBackground = Color(0x2BFFFFFF); // 17% white overlay
  static const Color glassCardBorder = Color(0x3DFFFFFF); // 24% white border
  static const Color darkNavBackground = Color(0xFF131F0F); // Organic deep dark green-black

  // Dashboard accent tint colors (icon chips, left-border rails, badges)
  static const Color tintGreenBg = Color(0xFFE3EEDD); // soft sage icon-chip bg
  static const Color tintGreenFg = Color(0xFF386A20);
  static const Color tintAmberBg = Color(0xFFFBEBD3); // soft harvest icon-chip bg
  static const Color tintAmberFg = Color(0xFFB1740A);
  static const Color tintBlueBg = Color(0xFFDDE9F7); // soft sky icon-chip bg
  static const Color tintBlueFg = Color(0xFF215C97);
  static const Color tintRedBg = Color(0xFFFAE0DE);
  static const Color tintRedFg = Color(0xFFBA1A1A);

  static const Color notificationDot = Color(0xFF3F8F1F);
  static const Color syncBannerBg = Color(0xFFE8F1E3);
  static const Color syncBannerBorder = Color(0xFFBFDBAE);

  // Dark Theme Palette
  static const Color primaryDarkTheme = Color(0xFF9CD67D); // High visibility light green
  static const Color secondaryDarkTheme = Color(0xFFE6C46A);
  static const Color backgroundDarkTheme = Color(0xFF071815); // Almost black, deep teal tint
  static const Color surfaceDarkTheme = Color(0xFF10211D); 
  static const Color cardBackgroundDarkTheme = Color(0xFF16281F);

  // Backdrop decoration (dark theme)
  static const Color backdropCirclePrimaryDark = Color(0xFF123B34);
  static const Color backdropCircleSecondaryDark = Color(0xFF1B4A42);
  static const Color backdropCircleAccentDark = Color(0xFF2E7D6F);

  static const Color textPrimaryDarkTheme = Color(0xFFE1E5DC);
  static const Color textSecondaryDarkTheme = Color(0xFFC2C9BD);
  static const Color borderDarkTheme = Color(0xFF43493E);
  static const Color dividerDarkTheme = Color(0xFF2D322B);

  // Dashboard accent tint colors (dark theme)
  static const Color tintGreenBgDark = Color(0xFF20301C);
  static const Color tintGreenFgDark = Color(0xFF9CD67D);
  static const Color tintAmberBgDark = Color(0xFF3A2E14);
  static const Color tintAmberFgDark = Color(0xFFE6C46A);
  static const Color tintBlueBgDark = Color(0xFF17293A);
  static const Color tintBlueFgDark = Color(0xFF7FB1E6);
  static const Color tintRedBgDark = Color(0xFF3A1E1C);
  static const Color tintRedFgDark = Color(0xFFE68A85);

  static const Color syncBannerBgDark = Color(0xFF1B2A17);
  static const Color syncBannerBorderDark = Color(0xFF33502A);
}
