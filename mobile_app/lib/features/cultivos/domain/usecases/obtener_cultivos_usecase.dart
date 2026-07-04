import '../entities/cultivo_entity.dart';
import '../repositories/cultivo_repository.dart';

class ObtenerCultivosPorParcelaUseCase {
  final CultivoRepository repository;
  const ObtenerCultivosPorParcelaUseCase(this.repository);

  Stream<List<CultivoEntity>> call(String parcelaId) =>
      repository.obtenerCultivosPorParcela(parcelaId);
}

class ObtenerCultivosPorUsuarioUseCase {
  final CultivoRepository repository;
  const ObtenerCultivosPorUsuarioUseCase(this.repository);

  Stream<List<CultivoEntity>> call(String usuarioId) =>
      repository.obtenerCultivosPorUsuario(usuarioId);
}
