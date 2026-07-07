import '../entities/diagnostico_entity.dart';
import '../repositories/diagnostico_repository.dart';

class EliminarDiagnosticoUseCase {
  final DiagnosticoRepository repository;
  const EliminarDiagnosticoUseCase(this.repository);

  Future<void> call(DiagnosticoEntity diagnostico) =>
      repository.eliminarDiagnostico(diagnostico);
}
