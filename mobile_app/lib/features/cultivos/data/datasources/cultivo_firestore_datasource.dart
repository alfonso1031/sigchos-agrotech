import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/cultivo_model.dart';

class CultivoFirestoreDataSource {
  final FirebaseFirestore _firestore;
  CultivoFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _cultivos =>
      _firestore.collection(FirestorePaths.cultivos);

  Future<String> crearCultivo(CultivoModel cultivo) async {
    final doc = await _cultivos.add(cultivo.toMap());
    return doc.id;
  }

  Stream<List<CultivoModel>> obtenerCultivosPorParcela(String parcelaId) {
    return _cultivos
        .where('parcelaId', isEqualTo: parcelaId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CultivoModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<CultivoModel>> obtenerCultivosPorUsuario(String usuarioId) {
    return _cultivos
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CultivoModel.fromMap(d.id, d.data()))
            .toList());
  }
}
