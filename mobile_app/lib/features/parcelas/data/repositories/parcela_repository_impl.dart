import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/parcela_entity.dart';
import '../../domain/repositories/parcela_repository.dart';
import '../datasources/parcela_firestore_datasource.dart';
import '../models/parcela_model.dart';

class ParcelaRepositoryImpl implements ParcelaRepository {
  final ParcelaFirestoreDataSource dataSource;
  const ParcelaRepositoryImpl(this.dataSource);

  @override
  Future<String> crearParcela(ParcelaEntity parcela) async {
    try {
      return await dataSource.crearParcela(ParcelaModel.fromEntity(parcela));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo guardar la parcela.');
    }
  }

  @override
  Future<void> actualizarParcela(ParcelaEntity parcela) async {
    try {
      await dataSource.actualizarParcela(ParcelaModel.fromEntity(parcela));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo actualizar la parcela.');
    }
  }

  @override
  Stream<List<ParcelaEntity>> obtenerParcelasPorFinca(String fincaId) {
    return dataSource.obtenerParcelasPorFinca(fincaId);
  }

  @override
  Stream<List<ParcelaEntity>> obtenerParcelasPorUsuario(String usuarioId) {
    return dataSource.obtenerParcelasPorUsuario(usuarioId);
  }
}
