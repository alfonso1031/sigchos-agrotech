import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/usuario_entity.dart';

class UsuarioModel extends UsuarioEntity {
  const UsuarioModel({
    required super.uid,
    required super.nombre,
    required super.cedula,
    required super.telefono,
    required super.email,
    required super.fechaRegistro,
    super.fotoUrl,
  });

  factory UsuarioModel.fromMap(String uid, Map<String, dynamic> map) {
    return UsuarioModel(
      uid: uid,
      nombre: map['nombre'] as String? ?? '',
      cedula: map['cedula'] as String? ?? '',
      telefono: map['telefono'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String?,
      fechaRegistro: (map['fechaRegistro'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'email': email,
      'rol': 'agricultor',
      'fotoUrl': fotoUrl,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }
}
