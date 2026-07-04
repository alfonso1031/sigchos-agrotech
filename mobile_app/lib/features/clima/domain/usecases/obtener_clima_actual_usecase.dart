import '../entities/clima_actual_entity.dart';
import '../repositories/clima_repository.dart';

class ObtenerClimaActualUseCase {
  final ClimaRepository repository;
  const ObtenerClimaActualUseCase(this.repository);

  Future<ClimaActualEntity> call({required double lat, required double lng}) {
    return repository.obtenerClimaActual(lat: lat, lng: lng);
  }
}
