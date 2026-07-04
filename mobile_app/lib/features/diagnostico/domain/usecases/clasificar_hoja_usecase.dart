import 'dart:io';
import '../entities/probabilidad_clase.dart';
import '../repositories/diagnostico_repository.dart';

class ClasificarHojaUseCase {
  final DiagnosticoRepository repository;
  const ClasificarHojaUseCase(this.repository);

  Future<List<ProbabilidadClase>> call(File imagen) =>
      repository.clasificarHoja(imagen);
}
