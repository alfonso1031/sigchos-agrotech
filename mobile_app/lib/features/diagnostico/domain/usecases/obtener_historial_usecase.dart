import '../entities/diagnostico_entity.dart';
import '../repositories/diagnostico_repository.dart';

class ObtenerHistorialUseCase {
  final DiagnosticoRepository repository;
  const ObtenerHistorialUseCase(this.repository);

  Stream<List<DiagnosticoEntity>> call(String usuarioId) =>
      repository.obtenerHistorial(usuarioId);
}
