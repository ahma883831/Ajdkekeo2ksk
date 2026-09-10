import 'package:flutter/material.dart';

/// Dark, neon-accented theme shared across the app.
class AppTheme {
  static const Color background = Color(0xFF0E0F1A);
  static const Color surface = Color(0xFF171927);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonCyan = Color(0xFF48F0E8);
  static const Color neonPink = Color(0xFFFF4FA3);
  static const Color textPrimary = Color(0xFFF5F5FF);
  static const Color textSecondary = Color(0xFFA0A3C0);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonPurple,
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonCyan,
        tertiary: neonPink,
        surface: surface,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: neonPurple.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Neon glow decoration used on practice module cards.
  static BoxDecoration glowCard(Color accent) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withOpacity(0.6), width: 1.2),
      boxShadow: [
        BoxShadow(color: accent.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
      ],
    );
  }
}
