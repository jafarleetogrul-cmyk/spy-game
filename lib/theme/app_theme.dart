import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary   = Color(0xFF6C63FF);
  static const secondary = Color(0xFFFF6584);
  static const accent    = Color(0xFF43E97B);
  static const surface   = Color(0xFF1E1E2E);
  static const bg        = Color(0xFF12121E);
  static const card      = Color(0xFF2A2A40);
  static const textMain  = Color(0xFFF2F2FF);
  static const textSub   = Color(0xFFAAAAAC);
  static const spyRed    = Color(0xFFFF4D4D);
  static const civilBlue = Color(0xFF4D9FFF);
  static const gold      = Color(0xFFFFD700);
  static const silver    = Color(0xFFC0C0C0);
  static const bronze    = Color(0xFFCD7F32);

  static const bgGrad      = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)]);
  static const primaryGrad = LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)]);
  static const spyGrad     = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B0000), Color(0xFFFF4D4D)]);
  static const civilGrad   = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF003366), Color(0xFF4D9FFF)]);
  static const goldGrad    = LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]);

  static ThemeData get dark {
    final b = ThemeData.dark(useMaterial3: true);
    return b.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: primary, secondary: secondary, surface: surface),
      textTheme: GoogleFonts.poppinsTextTheme(b.textTheme).apply(bodyColor: textMain, displayColor: textMain),
      appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, elevation: 0,
        titleTextStyle: GoogleFonts.poppins(color: textMain, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: textMain)),
      cardTheme: CardTheme(color: card, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        labelStyle: const TextStyle(color: textSub), hintStyle: const TextStyle(color: textSub),
      ),
    );
  }
}
