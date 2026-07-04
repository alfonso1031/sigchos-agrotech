import '../entities/recomendacion_entity.dart';
import '../repositories/recomendacion_repository.dart';

class ObtenerRecomendacionesUseCase {
  final RecomendacionRepository repository;
  const ObtenerRecomendacionesUseCase(this.repository);

  Future<List<RecomendacionEntity>> call(String claseId) =>
      repository.obtenerPorEnfermedad(claseId);
}
