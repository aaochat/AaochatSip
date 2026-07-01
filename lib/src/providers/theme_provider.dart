import 'package:flutter/material.dart';

/// Teal-based theme — visually distinct from TeamLocus indigo and old deep-orange template.
class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  static const Color primaryTeal = Color(0xFF00897B);
  static const Color accentTeal = Color(0xFF4DB6AC);
  static const Color surfaceDark = Color(0xFF1A1D21);
  static const Color cardDark = Color(0xFF252A30);

  ThemeProvider() {
    currentTheme = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: primaryTeal,
        secondary: accentTeal,
        surface: surfaceDark,
      ),
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: surfaceDark,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.all(12),
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentTeal, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardDark,
        surfaceTintColor: cardDark,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      cardTheme: const CardTheme(color: cardDark),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: accentTeal,
        unselectedItemColor: Colors.grey,
        backgroundColor: cardDark,
      ),
    );
  }

}
