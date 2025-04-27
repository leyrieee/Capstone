import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Common Text Theme
const _baseTextTheme = TextTheme(
  displayLarge: TextStyle(
      fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -0.02),
  displayMedium: TextStyle(
      fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.02),
  displaySmall: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.02),
  headlineLarge: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.02),
  headlineMedium: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.02),
  headlineSmall: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.02),
  titleLarge: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.02),
  titleMedium: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.02),
  titleSmall: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -0.02),
  bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.02),
  bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.02),
  bodySmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: -0.02),
  labelLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -0.02),
  labelMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.02),
  labelSmall: TextStyle(
      fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: -0.02),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, brightness: Brightness.light),
  textTheme: GoogleFonts.poppinsTextTheme(_baseTextTheme.apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  )),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black87,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black87,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.deepPurple),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    labelStyle: const TextStyle(color: Colors.black54),
    hintStyle: const TextStyle(color: Colors.grey),
  ),
  dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.8),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, brightness: Brightness.dark),
  textTheme: GoogleFonts.poppinsTextTheme(_baseTextTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  )),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.white,
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade800),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.deepPurple),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    labelStyle: const TextStyle(color: Colors.white54),
    hintStyle: const TextStyle(color: Colors.grey),
  ),
  dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.8),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
