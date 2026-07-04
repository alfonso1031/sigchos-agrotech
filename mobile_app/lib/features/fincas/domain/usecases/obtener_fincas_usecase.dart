import '../entities/finca_entity.dart';
import '../repositories/finca_repository.dart';

class ObtenerFincasUseCase {
  final FincaRepository repository;
  const ObtenerFincasUseCase(this.repository);

  Stream<List<FincaEntity>> call(String usuarioId) =>
      repository.obtenerFincasPorUsuario(usuarioId);
}
