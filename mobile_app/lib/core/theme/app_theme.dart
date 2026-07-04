import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema global de la app, replicando tipografía y radios del prototipo:
/// Space Grotesk (títulos), DM Sans (cuerpo), DM Mono (datos/labels).
class AppTheme {
  AppTheme._();

  static TextStyle displayFont({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textoPrimario,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle bodyFont({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textoPrimario,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle monoFont({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textoSecundario,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static const double radiusCard = 20;
  static const double radiusCardSm = 16;
  static const double radiusInput = 14;
  static const double radiusButton = 15;
  static const double radiusChip = 100;
  static const double alturaInput = 52;
  static const double alturaBoton = 54;

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fondoApp,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.verdeOscuro,
        secondary: AppColors.naranja,
        surface: AppColors.card,
        error: AppColors.severidadAlta,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        headlineSmall: displayFont(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: displayFont(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: displayFont(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.fondoApp,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: displayFont(fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: AppColors.textoPrimario),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdeMedio,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(alturaBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: displayFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.verdeMedio, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.severidadAlta),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }
}
