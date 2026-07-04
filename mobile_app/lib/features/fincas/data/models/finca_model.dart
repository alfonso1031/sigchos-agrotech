import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/finca_entity.dart';

class FincaModel extends FincaEntity {
  const FincaModel({
    required super.id,
    required super.usuarioId,
    required super.nombre,
    required super.lat,
    required super.lng,
    required super.direccion,
    required super.areaHectareas,
    required super.fechaCreacion,
  });

  factory FincaModel.fromMap(String id, Map<String, dynamic> map) {
    final ubicacion = map['ubicacion'] as GeoPoint?;
    return FincaModel(
      id: id,
      usuarioId: map['usuarioId'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      lat: ubicacion?.latitude ?? 0,
      lng: ubicacion?.longitude ?? 0,
      direccion: map['direccion'] as String? ?? '',
      areaHectareas: (map['areaHectareas'] as num?)?.toDouble() ?? 0,
      fechaCreacion:
          (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'ubicacion': GeoPoint(lat, lng),
      'direccion': direccion,
      'areaHectareas': areaHectareas,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  factory FincaModel.fromEntity(FincaEntity e) => FincaModel(
        id: e.id,
        usuarioId: e.usuarioId,
        nombre: e.nombre,
        lat: e.lat,
        lng: e.lng,
        direccion: e.direccion,
        areaHectareas: e.areaHectareas,
        fechaCreacion: e.fechaCreacion,
      );
}
