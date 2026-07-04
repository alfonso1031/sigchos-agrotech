import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoFirestoreDataSource {
  final FirebaseFirestore _firestore;
  DiagnosticoFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _diagnosticos =>
      _firestore.collection(FirestorePaths.diagnosticosHojas);

  Future<DiagnosticoModel> crear(DiagnosticoModel diagnostico) async {
    final doc = await _diagnosticos.add(diagnostico.toMap());
    return DiagnosticoModel.fromMap(doc.id, diagnostico.toMap());
  }

  Stream<List<DiagnosticoModel>> obtenerHistorial(String usuarioId) {
    return _diagnosticos
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DiagnosticoModel.fromMap(d.id, d.data()))
            .toList());
  }
}
