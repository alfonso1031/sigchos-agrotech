import 'package:flutter/material.dart';

/// Misma paleta que la app móvil (ver mobile_app/lib/core/theme/app_colors.dart
/// y PLAN.md sección 13.1) — se duplica porque son dos proyectos Flutter
/// independientes sin paquete compartido.
class AppColors {
  AppColors._();

  static const Color verdeOscuro = Color(0xFF225C3B);
  static const Color verdeMedio = Color(0xFF2E7D4F);
  static const Color verdeSidebar = Color(0xFF1C3A29);
  static const Color naranja = Color(0xFFE08A2B);

  static const Color fondoAdmin = Color(0xFFF1EEE5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE7E3D8);
  static const Color divider = Color(0xFFEFEBE0);

  static const Color textoPrimario = Color(0xFF1B2D22);
  static const Color textoSecundario = Color(0xFF717A70);
  static const Color textoDeshabilitado = Color(0xFF9AA197);

  static const Color severidadAlta = Color(0xFFC9533A);
  static const Color severidadAltaBg = Color(0xFFFBE9E4);
  static const Color severidadMedia = Color(0xFFC08A1E);
  static const Color severidadMediaBg = Color(0xFFFBF1DE);
  static const Color sano = Color(0xFF2E9E5E);
  static const Color sanoBg = Color(0xFFE4F0E6);

  static const Color mildiu = Color(0xFFB5562F);
  static const Color amarillamiento = Color(0xFFC9A227);
  static const Color plaga = Color(0xFFA8743B);

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
      case 'dano_plaga':
        return plaga;
      default:
        return textoDeshabilitado;
    }
  }

  static Color fondoResultado(String claseId) =>
      claseId == 'hoja_sana' ? sanoBg : severidadAltaBg;
}
