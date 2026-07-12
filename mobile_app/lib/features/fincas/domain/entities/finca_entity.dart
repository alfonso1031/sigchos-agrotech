import '../../../../core/models/geo_punto.dart';

class FincaEntity {
  final String id;
  final String usuarioId;
  final String nombre;
  final double lat;
  final double lng;
  final String direccion;
  final double areaHectareas;
  final DateTime fechaCreacion;

  /// Vértices del contorno de la finca (polígono). Vacío en fincas antiguas
  /// que solo guardaron un punto GPS; en ese caso se pinta un marcador.
  final List<GeoPunto> limite;

  const FincaEntity({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.direccion,
    required this.areaHectareas,
    required this.fechaCreacion,
    this.limite = const [],
  });

  bool get tienePoligono => limite.length >= 3;
}
