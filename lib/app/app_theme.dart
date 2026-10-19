import 'package:flutter/material.dart';

class AppTheme {
  static const blue = Color(0xFF2878F0);
  static const ink = Color(0xFF172B4D);
  static const muted = Color(0xFF718096);
  static const page = Color(0xFFF5F8FC);
  static const line = Color(0xFFE5ECF5);
  static const paleBlue = Color(0xFFEAF2FF);
  static const green = Color(0xFF2CA789);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: page,
        colorScheme: ColorScheme.fromSeed(seedColor: blue).copyWith(
          primary: blue,
          surface: Colors.white,
          secondary: green,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: page,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ink),
          bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.35),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: line, width: 0.8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: blue,
            disabledBackgroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF9CB5DD),
            elevation: 0.5,
            shadowColor: const Color(0x142878F0),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: BorderSide.none),
          ).copyWith(
            side: const WidgetStatePropertyAll(BorderSide.none),
            overlayColor: WidgetStatePropertyAll(blue.withOpacity(.06)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: blue,
            side: BorderSide.none,
            elevation: 0.5,
            shadowColor: const Color(0x142878F0),
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: BorderSide.none),
          ).copyWith(
            side: const WidgetStatePropertyAll(BorderSide.none),
            overlayColor: WidgetStatePropertyAll(blue.withOpacity(.06)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: blue,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Color(0xFF9AA8BB), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: blue, width: 1.3)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE46D72))),
        ),
        dividerTheme: const DividerThemeData(color: line, thickness: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: blue,
          unselectedItemColor: muted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
      );
}
