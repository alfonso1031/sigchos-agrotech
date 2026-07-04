import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parcela_entity.dart';

class ParcelaModel extends ParcelaEntity {
  const ParcelaModel({
    required super.id,
    required super.fincaId,
    required super.usuarioId,
    required super.nombre,
    required super.areaHectareas,
    required super.lat,
    required super.lng,
    required super.fechaCreacion,
  });

  factory ParcelaModel.fromMap(String id, Map<String, dynamic> map) {
    final ubicacion = map['ubicacion'] as GeoPoint?;
    return ParcelaModel(
      id: id,
      fincaId: map['fincaId'] as String? ?? '',
      usuarioId: map['usuarioId'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      areaHectareas: (map['areaHectareas'] as num?)?.toDouble() ?? 0,
      lat: ubicacion?.latitude ?? 0,
      lng: ubicacion?.longitude ?? 0,
      fechaCreacion:
          (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fincaId': fincaId,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'areaHectareas': areaHectareas,
      'ubicacion': GeoPoint(lat, lng),
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  factory ParcelaModel.fromEntity(ParcelaEntity e) => ParcelaModel(
        id: e.id,
        fincaId: e.fincaId,
        usuarioId: e.usuarioId,
        nombre: e.nombre,
        areaHectareas: e.areaHectareas,
        lat: e.lat,
        lng: e.lng,
        fechaCreacion: e.fechaCreacion,
      );
}
