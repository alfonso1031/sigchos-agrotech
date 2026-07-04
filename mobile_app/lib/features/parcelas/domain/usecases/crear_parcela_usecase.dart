import '../entities/parcela_entity.dart';
import '../repositories/parcela_repository.dart';

class CrearParcelaUseCase {
  final ParcelaRepository repository;
  const CrearParcelaUseCase(this.repository);

  Future<String> call(ParcelaEntity parcela) =>
      repository.crearParcela(parcela);
}

class ActualizarParcelaUseCase {
  final ParcelaRepository repository;
  const ActualizarParcelaUseCase(this.repository);

  Future<void> call(ParcelaEntity parcela) =>
      repository.actualizarParcela(parcela);
}
