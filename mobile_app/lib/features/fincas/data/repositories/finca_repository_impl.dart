import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/finca_entity.dart';
import '../../domain/repositories/finca_repository.dart';
import '../datasources/finca_firestore_datasource.dart';
import '../models/finca_model.dart';

class FincaRepositoryImpl implements FincaRepository {
  final FincaFirestoreDataSource dataSource;
  const FincaRepositoryImpl(this.dataSource);

  @override
  Future<String> crearFinca(FincaEntity finca) async {
    try {
      return await dataSource.crearFinca(FincaModel.fromEntity(finca));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo guardar la finca.');
    }
  }

  @override
  Future<void> actualizarFinca(FincaEntity finca) async {
    try {
      await dataSource.actualizarFinca(FincaModel.fromEntity(finca));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo actualizar la finca.');
    }
  }

  @override
  Stream<List<FincaEntity>> obtenerFincasPorUsuario(String usuarioId) {
    return dataSource.obtenerFincasPorUsuario(usuarioId);
  }
}
