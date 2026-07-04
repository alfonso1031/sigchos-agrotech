import '../entities/pronostico_dia_entity.dart';
import '../repositories/clima_repository.dart';

class ObtenerPronosticoUseCase {
  final ClimaRepository repository;
  const ObtenerPronosticoUseCase(this.repository);

  Future<List<PronosticoDiaEntity>> call({
    required double lat,
    required double lng,
  }) {
    return repository.obtenerPronostico(lat: lat, lng: lng);
  }
}
