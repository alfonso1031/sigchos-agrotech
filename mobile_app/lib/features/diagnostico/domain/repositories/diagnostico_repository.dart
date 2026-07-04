import 'dart:io';
import '../entities/diagnostico_entity.dart';
import '../entities/probabilidad_clase.dart';

abstract class DiagnosticoRepository {
  Future<List<ProbabilidadClase>> clasificarHoja(File imagen);

  Future<DiagnosticoEntity> crearDiagnostico({
    required DiagnosticoEntity diagnostico,
    required File imagen,
  });

  Stream<List<DiagnosticoEntity>> obtenerHistorial(String usuarioId);
}
