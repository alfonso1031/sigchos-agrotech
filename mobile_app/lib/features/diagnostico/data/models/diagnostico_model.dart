import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clima_snapshot.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/entities/probabilidad_clase.dart';

class DiagnosticoModel extends DiagnosticoEntity {
  const DiagnosticoModel({
    required super.id,
    required super.usuarioId,
    required super.cultivoId,
    required super.imagenUrl,
    required super.enfermedad,
    required super.confianza,
    required super.top3,
    required super.fecha,
    super.lat,
    super.lng,
    super.clima,
  });

  factory DiagnosticoModel.fromMap(String id, Map<String, dynamic> map) {
    final ubicacion = map['ubicacion'] as GeoPoint?;
    final climaMap = map['climaSnapshot'] as Map<String, dynamic>?;
    final top3Raw = (map['top3'] as List?) ?? [];

    return DiagnosticoModel(
      id: id,
      usuarioId: map['usuarioId'] as String? ?? '',
      cultivoId: map['cultivoId'] as String? ?? '',
      imagenUrl: map['imagenUrl'] as String? ?? '',
      enfermedad: map['enfermedad'] as String? ?? '',
      confianza: (map['confianza'] as num?)?.toDouble() ?? 0,
      top3: top3Raw
          .map((e) => ProbabilidadClase(
                (e as Map)['clase'] as String,
                (e['prob'] as num).toDouble(),
              ))
          .toList(),
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lat: ubicacion?.latitude,
      lng: ubicacion?.longitude,
      clima: climaMap == null
          ? null
          : ClimaSnapshot(
              temperatura: (climaMap['temp'] as num).toDouble(),
              humedad: (climaMap['humedad'] as num).toInt(),
              descripcion: climaMap['descripcion'] as String,
            ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'cultivoId': cultivoId,
      'imagenUrl': imagenUrl,
      'enfermedad': enfermedad,
      'confianza': confianza,
      'top3': top3.map((p) => {'clase': p.claseId, 'prob': p.probabilidad}).toList(),
      'fecha': Timestamp.fromDate(fecha),
      if (lat != null && lng != null) 'ubicacion': GeoPoint(lat!, lng!),
      if (clima != null)
        'climaSnapshot': {
          'temp': clima!.temperatura,
          'humedad': clima!.humedad,
          'descripcion': clima!.descripcion,
        },
    };
  }

  factory DiagnosticoModel.fromEntity(DiagnosticoEntity e) => DiagnosticoModel(
        id: e.id,
        usuarioId: e.usuarioId,
        cultivoId: e.cultivoId,
        imagenUrl: e.imagenUrl,
        enfermedad: e.enfermedad,
        confianza: e.confianza,
        top3: e.top3,
        fecha: e.fecha,
        lat: e.lat,
        lng: e.lng,
        clima: e.clima,
      );
}
