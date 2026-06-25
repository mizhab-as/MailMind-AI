import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  final String name;
  final bool isDark;
  final ThemeData themeData;
  final Color background;
  final Color cardBg;
  final Color accent;
  final Color textMain;
  final Color textMuted;

  AppTheme({
    required this.name,
    required this.isDark,
    required this.themeData,
    required this.background,
    required this.cardBg,
    required this.accent,
    required this.textMain,
    required this.textMuted,
  });
}

class MailMindTheme {
  // Global reference to the current active theme
  static AppTheme currentTheme = cyberpunkTheme;

  static Color get background => currentTheme.background;
  static Color get cardBg => currentTheme.cardBg;
  static Color get accent => currentTheme.accent;
  static Color get textMain => currentTheme.textMain;
  static Color get textMuted => currentTheme.textMuted;

  // Custom glassmorphic decoration
  static BoxDecoration glassBox({
    Color? color,
    double radius = 16.0,
    double borderOpacity = 0.08,
  }) {
    return BoxDecoration(
      color: color ?? currentTheme.cardBg.withOpacity(0.4),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: currentTheme.textMain.withOpacity(borderOpacity),
        width: 1.0,
      ),
    );
  }

  // Priority color indicators
  static Color getPriorityColor(int score) {
    if (score >= 80) return const Color(0xFFFF5E5B); // Red
    if (score >= 60) return const Color(0xFFFFB86C); // Orange/Amber
    return const Color(0xFF2EC4B6); // Emerald Green
  }

  // 1. Cyberpunk Neon (Dark)
  static final AppTheme cyberpunkTheme = AppTheme(
    name: 'Cyberpunk Neon',
    isDark: true,
    background: const Color(0xFF0F0E17),
    cardBg: const Color(0xFF16161A),
    accent: const Color(0xFF7F5AF0),
    textMain: const Color(0xFFFFFEFE),
    textMuted: const Color(0xFF94A1B2),
    themeData: _buildDarkThemeData(
      background: const Color(0xFF0F0E17),
      cardBg: const Color(0xFF16161A),
      accent: const Color(0xFF7F5AF0),
      secondary: const Color(0xFF2CB67D),
      textMain: const Color(0xFFFFFEFE),
      textMuted: const Color(0xFF94A1B2),
    ),
  );

  // 2. Midnight Sunset (Dark)
  static final AppTheme sunsetTheme = AppTheme(
    name: 'Midnight Sunset',
    isDark: true,
    background: const Color(0xFF0B0A12),
    cardBg: const Color(0xFF16121E),
    accent: const Color(0xFFFF5E5B),
    textMain: const Color(0xFFFFF3F3),
    textMuted: const Color(0xFFA594B2),
    themeData: _buildDarkThemeData(
      background: const Color(0xFF0B0A12),
      cardBg: const Color(0xFF16121E),
      accent: const Color(0xFFFF5E5B),
      secondary: const Color(0xFFFFB86C),
      textMain: const Color(0xFFFFF3F3),
      textMuted: const Color(0xFFA594B2),
    ),
  );

  // 3. Emerald Forest (Dark)
  static final AppTheme forestTheme = AppTheme(
    name: 'Emerald Forest',
    isDark: true,
    background: const Color(0xFF0A0F0D),
    cardBg: const Color(0xFF131B18),
    accent: const Color(0xFF2EC4B6),
    textMain: const Color(0xFFF1F8F6),
    textMuted: const Color(0xFF8DA39C),
    themeData: _buildDarkThemeData(
      background: const Color(0xFF0A0F0D),
      cardBg: const Color(0xFF131B18),
      accent: const Color(0xFF2EC4B6),
      secondary: const Color(0xFF2CB67D),
      textMain: const Color(0xFFF1F8F6),
      textMuted: const Color(0xFF8DA39C),
    ),
  );

  // 4. Nordic Frost (Dark)
  static final AppTheme nordTheme = AppTheme(
    name: 'Nordic Frost',
    isDark: true,
    background: const Color(0xFF1A1F29),
    cardBg: const Color(0xFF242B38),
    accent: const Color(0xFF88C0D0),
    textMain: const Color(0xFFECEFF4),
    textMuted: const Color(0xFFB4BE82),
    themeData: _buildDarkThemeData(
      background: const Color(0xFF1A1F29),
      cardBg: const Color(0xFF242B38),
      accent: const Color(0xFF88C0D0),
      secondary: const Color(0xFF8FBCBB),
      textMain: const Color(0xFFECEFF4),
      textMuted: const Color(0xFFB4BE82),
    ),
  );

  // 5. Slate Minimalist (Light)
  static final AppTheme lightTheme = AppTheme(
    name: 'Slate Minimalist',
    isDark: false,
    background: const Color(0xFFF8FAFC),
    cardBg: const Color(0xFFFFFFFF),
    accent: const Color(0xFF6366F1),
    textMain: const Color(0xFF0F172A),
    textMuted: const Color(0xFF475569),
    themeData: _buildLightThemeData(
      background: const Color(0xFFF8FAFC),
      cardBg: const Color(0xFFFFFFFF),
      accent: const Color(0xFF6366F1),
      secondary: const Color(0xFF0EA5E9),
      textMain: const Color(0xFF0F172A),
      textMuted: const Color(0xFF475569),
    ),
  );

  static final List<AppTheme> themes = [
    cyberpunkTheme,
    sunsetTheme,
    forestTheme,
    nordTheme,
    lightTheme,
  ];

  static ThemeData _buildDarkThemeData({
    required Color background,
    required Color cardBg,
    required Color accent,
    required Color secondary,
    required Color textMain,
    required Color textMuted,
  }) {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: cardBg,
        onSurface: textMain,
        error: const Color(0xFFFF5E5B),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: textMain),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: textMain),
          bodyLarge: TextStyle(color: textMain),
          bodyMedium: TextStyle(color: textMuted),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textMain.withOpacity(0.05)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textMain.withOpacity(0.08),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textMain.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  static ThemeData _buildLightThemeData({
    required Color background,
    required Color cardBg,
    required Color accent,
    required Color secondary,
    required Color textMain,
    required Color textMuted,
  }) {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: secondary,
        surface: cardBg,
        onSurface: textMain,
        error: const Color(0xFFD32F2F),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.copyWith(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: textMain),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: textMain),
          bodyLarge: TextStyle(color: textMain),
          bodyMedium: TextStyle(color: textMuted),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textMain.withOpacity(0.08)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textMain.withOpacity(0.08),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textMain.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
