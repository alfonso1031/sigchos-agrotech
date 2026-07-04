import '../../domain/entities/recomendacion_entity.dart';

class RecomendacionModel extends RecomendacionEntity {
  const RecomendacionModel({
    required super.id,
    required super.enfermedad,
    required super.orden,
    required super.titulo,
    required super.descripcion,
  });

  factory RecomendacionModel.fromMap(String id, Map<String, dynamic> map) {
    return RecomendacionModel(
      id: id,
      enfermedad: map['enfermedad'] as String? ?? '',
      orden: (map['orden'] as num?)?.toInt() ?? 0,
      titulo: map['titulo'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
    );
  }
}
