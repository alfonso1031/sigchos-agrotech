import 'dart:math' as math;
import '../models/geo_punto.dart';

/// Utilidades geográficas para trabajar con polígonos de fincas.
class GeoUtils {
  GeoUtils._();

  /// Área en hectáreas de un polígono definido por sus vértices (en orden).
  /// Usa la fórmula de área esférica; devuelve 0 si hay menos de 3 puntos.
  static double areaHectareas(List<GeoPunto> puntos) {
    if (puntos.length < 3) return 0;
    const radioTierra = 6378137.0; // metros
    double suma = 0;
    for (var i = 0; i < puntos.length; i++) {
      final p1 = puntos[i];
      final p2 = puntos[(i + 1) % puntos.length];
      suma += _rad(p2.lng - p1.lng) *
          (2 + math.sin(_rad(p1.lat)) + math.sin(_rad(p2.lat)));
    }
    final areaM2 = (suma * radioTierra * radioTierra / 2).abs();
    return areaM2 / 10000; // m² → ha
  }

  /// Centro (promedio de vértices) del polígono. Sirve como punto único para
  /// pintar un marcador o centrar la cámara. Devuelve null si la lista es vacía.
  static GeoPunto? centroide(List<GeoPunto> puntos) {
    if (puntos.isEmpty) return null;
    double lat = 0, lng = 0;
    for (final p in puntos) {
      lat += p.lat;
      lng += p.lng;
    }
    return GeoPunto(lat / puntos.length, lng / puntos.length);
  }

  static double _rad(double grados) => grados * math.pi / 180;
}
