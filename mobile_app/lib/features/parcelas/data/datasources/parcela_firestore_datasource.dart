import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/parcela_model.dart';

class ParcelaFirestoreDataSource {
  final FirebaseFirestore _firestore;
  ParcelaFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _parcelas =>
      _firestore.collection(FirestorePaths.parcelas);

  Future<String> crearParcela(ParcelaModel parcela) async {
    final doc = await _parcelas.add(parcela.toMap());
    return doc.id;
  }

  Future<void> actualizarParcela(ParcelaModel parcela) async {
    await _parcelas.doc(parcela.id).update({
      'nombre': parcela.nombre,
      'areaHectareas': parcela.areaHectareas,
      'ubicacion': GeoPoint(parcela.lat, parcela.lng),
    });
  }

  Stream<List<ParcelaModel>> obtenerParcelasPorFinca(String fincaId) {
    return _parcelas
        .where('fincaId', isEqualTo: fincaId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ParcelaModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<ParcelaModel>> obtenerParcelasPorUsuario(String usuarioId) {
    return _parcelas
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ParcelaModel.fromMap(d.id, d.data()))
            .toList());
  }
}
