import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/finca_model.dart';

class FincaFirestoreDataSource {
  final FirebaseFirestore _firestore;
  FincaFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _fincas =>
      _firestore.collection(FirestorePaths.fincas);

  Future<String> crearFinca(FincaModel finca) async {
    final doc = await _fincas.add(finca.toMap());
    return doc.id;
  }

  Future<void> actualizarFinca(FincaModel finca) async {
    await _fincas.doc(finca.id).update({
      'nombre': finca.nombre,
      'ubicacion': GeoPoint(finca.lat, finca.lng),
      'direccion': finca.direccion,
      'areaHectareas': finca.areaHectareas,
      'limite': finca.limite.map((p) => GeoPoint(p.lat, p.lng)).toList(),
    });
  }

  Stream<List<FincaModel>> obtenerFincasPorUsuario(String usuarioId) {
    return _fincas
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FincaModel.fromMap(d.id, d.data()))
            .toList());
  }
}
