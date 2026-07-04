import 'package:flutter/material.dart';

/// Paleta extraída del prototipo Claude Design (Sigchos Agrotech.dc.html).
class AppColors {
  AppColors._();

  static const Color verdeOscuro = Color(0xFF225C3B);
  static const Color verdeMedio = Color(0xFF2E7D4F);
  static const Color verdeClaro = Color(0xFF359659);
  static const Color verdeSidebar = Color(0xFF1C3A29);
  static const Color naranja = Color(0xFFE08A2B);
  static const Color naranjaClaro = Color(0xFFF0B775);

  static const Color fondoApp = Color(0xFFF4F1E9);
  static const Color fondoAdmin = Color(0xFFF1EEE5);
  static const Color fondoCamara = Color(0xFF111613);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE7E3D8);
  static const Color divider = Color(0xFFEFEBE0);
  static const Color inputFill = Color(0xFFF6F4EE);

  static const Color textoPrimario = Color(0xFF1B2D22);
  static const Color textoSecundario = Color(0xFF717A70);
  static const Color textoDeshabilitado = Color(0xFF9AA197);

  static const Color severidadAlta = Color(0xFFC9533A);
  static const Color severidadAltaBg = Color(0xFFFBE9E4);
  static const Color severidadMedia = Color(0xFFDBA42E);
  static const Color severidadMediaBg = Color(0xFFFBF1DE);
  static const Color sano = Color(0xFF2E9E5E);
  static const Color sanoBg = Color(0xFFE4F0E6);

  static const Color alertaTexto = Color(0xFF8A5A12);
  static const Color alertaFondo = Color(0xFFFBF3E6);
  static const Color alertaBorde = Color(0xFFF0DCBE);

  static const Color mildiu = Color(0xFFB5562F);
  static const Color amarillamiento = Color(0xFFC9A227);

  static const LinearGradient gradienteLogin = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF225C3B), Color(0xFF2E7D4F), Color(0xFF256340)],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient gradienteClima = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D4F), Color(0xFF225C3B)],
  );

  static const LinearGradient gradienteCTA = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D4F), Color(0xFF359659)],
  );

  /// Color asociado a cada clase de enfermedad detectada.
  static Color colorEnfermedad(String claseId) {
    switch (claseId) {
      case 'hoja_sana':
        return sano;
      case 'mancha_foliar':
        return severidadAlta;
      case 'mildiu':
        return mildiu;
      case 'oidio':
        return severidadMedia;
      case 'amarillamiento':
        return amarillamiento;
      default:
        return textoDeshabilitado;
    }
  }

  static Color fondoEnfermedad(String claseId) {
    switch (claseId) {
      case 'hoja_sana':
        return sanoBg;
      case 'mancha_foliar':
      case 'mildiu':
        return severidadAltaBg;
      default:
        return severidadMediaBg;
    }
  }
}
