import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary    = Color(0xFF0F172A); // deep navy
  static const Color accent     = Color(0xFF6366F1); // indigo
  static const Color lostColor  = Color(0xFFEF4444); // red
  static const Color foundColor = Color(0xFF10B981); // emerald
  static const Color bgLight    = Color(0xFFF8FAFC);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color textMuted  = Color(0xFF94A3B8);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: primary,
      secondary: accent,
      surface: bgLight,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lostColor),
      ),
    ),
  );
}