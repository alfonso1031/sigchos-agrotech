import '../../domain/entities/recomendacion_entity.dart';
import '../../domain/repositories/recomendacion_repository.dart';
import '../datasources/recomendacion_firestore_datasource.dart';

class RecomendacionRepositoryImpl implements RecomendacionRepository {
  final RecomendacionFirestoreDataSource dataSource;
  const RecomendacionRepositoryImpl(this.dataSource);

  @override
  Future<List<RecomendacionEntity>> obtenerPorEnfermedad(String claseId) {
    return dataSource.obtenerPorEnfermedad(claseId);
  }
}
