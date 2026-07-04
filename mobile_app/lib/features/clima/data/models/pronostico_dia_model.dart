import '../../domain/entities/pronostico_dia_entity.dart';

class PronosticoDiaModel extends PronosticoDiaEntity {
  const PronosticoDiaModel({
    required super.dia,
    required super.tempMax,
    required super.tempMin,
    required super.probabilidadLluvia,
  });
}
