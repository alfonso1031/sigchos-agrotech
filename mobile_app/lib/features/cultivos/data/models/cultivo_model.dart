import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cultivo_entity.dart';

class CultivoModel extends CultivoEntity {
  const CultivoModel({
    required super.id,
    required super.parcelaId,
    required super.usuarioId,
    required super.variedad,
    required super.fechaSiembra,
    required super.plantasEstimadas,
    super.etapa,
    super.activo,
  });

  factory CultivoModel.fromMap(String id, Map<String, dynamic> map) {
    return CultivoModel(
      id: id,
      parcelaId: map['parcelaId'] as String? ?? '',
      usuarioId: map['usuarioId'] as String? ?? '',
      variedad: map['variedad'] as String? ?? 'Macre',
      fechaSiembra:
          (map['fechaSiembra'] as Timestamp?)?.toDate() ?? DateTime.now(),
      plantasEstimadas: (map['plantasEstimadas'] as num?)?.toInt() ?? 0,
      etapa: EtapaCultivo.values.firstWhere(
        (e) => e.name == map['etapa'],
        orElse: () => EtapaCultivo.germinacion,
      ),
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parcelaId': parcelaId,
      'usuarioId': usuarioId,
      'variedad': variedad,
      'fechaSiembra': Timestamp.fromDate(fechaSiembra),
      'plantasEstimadas': plantasEstimadas,
      'etapa': etapa.name,
      'activo': activo,
    };
  }

  factory CultivoModel.fromEntity(CultivoEntity e) => CultivoModel(
        id: e.id,
        parcelaId: e.parcelaId,
        usuarioId: e.usuarioId,
        variedad: e.variedad,
        fechaSiembra: e.fechaSiembra,
        plantasEstimadas: e.plantasEstimadas,
        etapa: e.etapa,
        activo: e.activo,
      );
}
