import '../entities/finca_entity.dart';
import '../repositories/finca_repository.dart';

class CrearFincaUseCase {
  final FincaRepository repository;
  const CrearFincaUseCase(this.repository);

  Future<String> call(FincaEntity finca) => repository.crearFinca(finca);
}

class ActualizarFincaUseCase {
  final FincaRepository repository;
  const ActualizarFincaUseCase(this.repository);

  Future<void> call(FincaEntity finca) => repository.actualizarFinca(finca);
}
