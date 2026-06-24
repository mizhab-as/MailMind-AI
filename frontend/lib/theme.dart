import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MailMindTheme {
  static const Color background = Color(0xFF0F0E17);
  static const Color cardBg = Color(0x15FFFFFF);
  static const Color accent = Color(0xFF7F5AF0);
  static const Color textMain = Color(0xFFFFFEFE);
  static const Color textMuted = Color(0xFF94A1B2);
  
  // Custom glassmorphic decoration
  static BoxDecoration glassBox({
    Color color = const Color(0x0EFFFFFF),
    double radius = 16.0,
    double borderOpacity = 0.08,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
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

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF2CB67D),
        surface: Color(0xFF16161A),
        onSurface: textMain,
        error: Color(0xFFFF5E5B),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.bold, color: textMain),
          titleMedium: const TextStyle(fontWeight: FontWeight.w600, color: textMain),
          bodyLarge: const TextStyle(color: textMain),
          bodyMedium: const TextStyle(color: textMuted),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16161A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
      ),
    );
  }
}
