import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioDoc {
  final String uid;
  final String nombre;
  final String correo;

  UsuarioDoc({required this.uid, required this.nombre, required this.correo});

  factory UsuarioDoc.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return UsuarioDoc(
      uid: d.id,
      nombre: m['nombre'] as String? ?? '(sin nombre)',
      correo: m['email'] as String? ?? '',
    );
  }
}

class FincaDoc {
  final String id;
  final String usuarioId;
  final String nombre;

  FincaDoc({required this.id, required this.usuarioId, required this.nombre});

  factory FincaDoc.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return FincaDoc(
      id: d.id,
      usuarioId: m['usuarioId'] as String? ?? '',
      nombre: m['nombre'] as String? ?? '',
    );
  }
}

class ParcelaDoc {
  final String id;
  final String fincaId;
  final String usuarioId;
  final String nombre;

  ParcelaDoc({
    required this.id,
    required this.fincaId,
    required this.usuarioId,
    required this.nombre,
  });

  factory ParcelaDoc.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return ParcelaDoc(
      id: d.id,
      fincaId: m['fincaId'] as String? ?? '',
      usuarioId: m['usuarioId'] as String? ?? '',
      nombre: m['nombre'] as String? ?? '',
    );
  }
}

class CultivoDoc {
  final String id;
  final String parcelaId;

  CultivoDoc({required this.id, required this.parcelaId});

  factory CultivoDoc.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return CultivoDoc(id: d.id, parcelaId: m['parcelaId'] as String? ?? '');
  }
}

class DiagnosticoDoc {
  final String id;
  final String usuarioId;
  final String cultivoId;
  final String enfermedad;
  final double confianza;
  final DateTime fecha;
  final double? lat;
  final double? lng;

  DiagnosticoDoc({
    required this.id,
    required this.usuarioId,
    required this.cultivoId,
    required this.enfermedad,
    required this.confianza,
    required this.fecha,
    this.lat,
    this.lng,
  });

  factory DiagnosticoDoc.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final ubicacion = m['ubicacion'] as GeoPoint?;
    return DiagnosticoDoc(
      id: d.id,
      usuarioId: m['usuarioId'] as String? ?? '',
      cultivoId: m['cultivoId'] as String? ?? '',
      enfermedad: m['enfermedad'] as String? ?? '',
      confianza: (m['confianza'] as num?)?.toDouble() ?? 0,
      fecha: (m['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lat: ubicacion?.latitude,
      lng: ubicacion?.longitude,
    );
  }
}
