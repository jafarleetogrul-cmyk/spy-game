import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colours ──────────────────────────
  static const Color primary   = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent    = Color(0xFF43E97B);
  static const Color surface   = Color(0xFF1E1E2E);
  static const Color bg        = Color(0xFF12121E);
  static const Color card      = Color(0xFF2A2A40);
  static const Color textMain  = Color(0xFFF2F2FF);
  static const Color textSub   = Color(0xFFAAAAAC);

  static const Color spyRed    = Color(0xFFFF4D4D);
  static const Color civilBlue = Color(0xFF4D9FFF);

  // ── Gradients ──────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
  );

  static const LinearGradient spyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B0000), Color(0xFFFF4D4D)],
  );

  static const LinearGradient civilGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003366), Color(0xFF4D9FFF)],
  );

  // ── ThemeData ──────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: bg,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 4,
        ),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSub),
        hintStyle: const TextStyle(color: textSub),
      ),
    );
  }
}
