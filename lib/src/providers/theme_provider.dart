import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  ThemeProvider() {
    currentTheme = ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF232932)),
      primaryColor: Color(0xFF232932),
      primaryColorLight: Color(0xFF232932),
      primaryColorDark: Color(0xFF232932),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.all(10.0),
        labelStyle: TextStyle(color: Colors.grey),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.grey.shade900,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        // style: ElevatedButton.styleFrom(
        //   padding: const EdgeInsets.all(16),
        //   textStyle: TextStyle(fontSize: 18),
        // ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 5,
          // Shadow
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
