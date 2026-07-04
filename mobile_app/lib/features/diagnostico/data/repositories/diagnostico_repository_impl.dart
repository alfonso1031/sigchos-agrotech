import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failure.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/tflite_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/entities/probabilidad_clase.dart';
import '../../domain/repositories/diagnostico_repository.dart';
import '../datasources/diagnostico_firestore_datasource.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoRepositoryImpl implements DiagnosticoRepository {
  final DiagnosticoFirestoreDataSource dataSource;
  final TFLiteService tfliteService;
  final StorageService storageService;

  const DiagnosticoRepositoryImpl({
    required this.dataSource,
    required this.tfliteService,
    required this.storageService,
  });

  @override
  Future<List<ProbabilidadClase>> clasificarHoja(File imagen) async {
    final resultados = await tfliteService.clasificar(imagen);
    return resultados
        .map((r) => ProbabilidadClase(r.claseId, r.probabilidad))
        .toList();
  }

  @override
  Future<DiagnosticoEntity> crearDiagnostico({
    required DiagnosticoEntity diagnostico,
    required File imagen,
  }) async {
    // La subida a Storage es tolerante a fallo: si Storage no está habilitado
    // (plan Blaze) o falla la red, el diagnóstico se guarda igual sin imagen en
    // la nube. Así el flujo de diagnóstico nunca se rompe por Storage.
    String urlImagen = '';
    try {
      urlImagen =
          await storageService.subirImagenHoja(imagen, diagnostico.usuarioId);
    } catch (_) {
      urlImagen = '';
    }

    try {
      final model = DiagnosticoModel.fromEntity(diagnostico);
      final conImagen = DiagnosticoModel(
        id: model.id,
        usuarioId: model.usuarioId,
        cultivoId: model.cultivoId,
        imagenUrl: urlImagen,
        enfermedad: model.enfermedad,
        confianza: model.confianza,
        top3: model.top3,
        fecha: model.fecha,
        lat: model.lat,
        lng: model.lng,
        clima: model.clima,
      );
      return await dataSource.crear(conImagen);
    } on FirebaseException catch (e) {
      throw ServerFailure(
        _mensajeFirestore(e.code) ?? 'No se pudo guardar el diagnóstico.',
      );
    }
  }

  String? _mensajeFirestore(String code) {
    switch (code) {
      case 'permission-denied':
        return 'No tienes permiso para guardar el diagnóstico. Revisa tu sesión.';
      case 'unavailable':
        return 'Sin conexión con el servidor. Revisa tu internet e intenta de nuevo.';
      default:
        return null;
    }
  }

  @override
  Stream<List<DiagnosticoEntity>> obtenerHistorial(String usuarioId) {
    return dataSource.obtenerHistorial(usuarioId);
  }
}
