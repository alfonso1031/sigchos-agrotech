import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/cultivo_entity.dart';
import '../../domain/repositories/cultivo_repository.dart';
import '../datasources/cultivo_firestore_datasource.dart';
import '../models/cultivo_model.dart';

class CultivoRepositoryImpl implements CultivoRepository {
  final CultivoFirestoreDataSource dataSource;
  const CultivoRepositoryImpl(this.dataSource);

  @override
  Future<String> crearCultivo(CultivoEntity cultivo) async {
    try {
      return await dataSource.crearCultivo(CultivoModel.fromEntity(cultivo));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo guardar el cultivo.');
    }
  }

  @override
  Stream<List<CultivoEntity>> obtenerCultivosPorParcela(String parcelaId) {
    return dataSource.obtenerCultivosPorParcela(parcelaId);
  }

  @override
  Stream<List<CultivoEntity>> obtenerCultivosPorUsuario(String usuarioId) {
    return dataSource.obtenerCultivosPorUsuario(usuarioId);
  }
}
