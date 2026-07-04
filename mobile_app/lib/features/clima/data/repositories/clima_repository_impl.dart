import '../../../../core/errors/failure.dart';
import '../../domain/entities/clima_actual_entity.dart';
import '../../domain/entities/pronostico_dia_entity.dart';
import '../../domain/repositories/clima_repository.dart';
import '../datasources/openweather_datasource.dart';

class ClimaRepositoryImpl implements ClimaRepository {
  final OpenWeatherDataSource dataSource;
  const ClimaRepositoryImpl(this.dataSource);

  @override
  Future<ClimaActualEntity> obtenerClimaActual({
    required double lat,
    required double lng,
  }) async {
    try {
      return await dataSource.obtenerClimaActual(lat, lng);
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el clima. Revisa tu conexión.');
    }
  }

  @override
  Future<List<PronosticoDiaEntity>> obtenerPronostico({
    required double lat,
    required double lng,
  }) async {
    try {
      return await dataSource.obtenerPronostico(lat, lng);
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el pronóstico.');
    }
  }
}
