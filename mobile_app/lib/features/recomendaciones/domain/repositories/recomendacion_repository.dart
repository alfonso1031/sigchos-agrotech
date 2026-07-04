import '../entities/recomendacion_entity.dart';

abstract class RecomendacionRepository {
  Future<List<RecomendacionEntity>> obtenerPorEnfermedad(String claseId);
}
