import '../entities/parcela_entity.dart';
import '../repositories/parcela_repository.dart';

class ObtenerParcelasPorFincaUseCase {
  final ParcelaRepository repository;
  const ObtenerParcelasPorFincaUseCase(this.repository);

  Stream<List<ParcelaEntity>> call(String fincaId) =>
      repository.obtenerParcelasPorFinca(fincaId);
}

class ObtenerParcelasPorUsuarioUseCase {
  final ParcelaRepository repository;
  const ObtenerParcelasPorUsuarioUseCase(this.repository);

  Stream<List<ParcelaEntity>> call(String usuarioId) =>
      repository.obtenerParcelasPorUsuario(usuarioId);
}
