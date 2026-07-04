import '../entities/cultivo_entity.dart';
import '../repositories/cultivo_repository.dart';

class CrearCultivoUseCase {
  final CultivoRepository repository;
  const CrearCultivoUseCase(this.repository);

  Future<String> call(CultivoEntity cultivo) =>
      repository.crearCultivo(cultivo);
}
