import '../entities/clima_actual_entity.dart';
import '../entities/pronostico_dia_entity.dart';

abstract class ClimaRepository {
  Future<ClimaActualEntity> obtenerClimaActual({
    required double lat,
    required double lng,
  });

  Future<List<PronosticoDiaEntity>> obtenerPronostico({
    required double lat,
    required double lng,
  });
}
