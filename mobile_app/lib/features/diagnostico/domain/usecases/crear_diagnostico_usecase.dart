import 'dart:io';
import '../entities/diagnostico_entity.dart';
import '../repositories/diagnostico_repository.dart';

class CrearDiagnosticoUseCase {
  final DiagnosticoRepository repository;
  const CrearDiagnosticoUseCase(this.repository);

  Future<DiagnosticoEntity> call({
    required DiagnosticoEntity diagnostico,
    required File imagen,
  }) =>
      repository.crearDiagnostico(diagnostico: diagnostico, imagen: imagen);
}
