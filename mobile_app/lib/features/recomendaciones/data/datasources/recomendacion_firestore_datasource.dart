import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/recomendacion_model.dart';
import 'recomendaciones_fallback.dart';

class RecomendacionFirestoreDataSource {
  final FirebaseFirestore _firestore;
  RecomendacionFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<RecomendacionModel>> obtenerPorEnfermedad(String claseId) async {
    // Tolerante a fallo: si la colección está vacía, no existe el índice
    // compuesto, o falla la red, se usa el contenido de respaldo local
    // (idéntico al del prototipo) para que las recomendaciones SIEMPRE carguen.
    try {
      final snap = await _firestore
          .collection(FirestorePaths.recomendaciones)
          .where('enfermedad', isEqualTo: claseId)
          .orderBy('orden')
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => RecomendacionModel.fromMap(d.id, d.data()))
            .toList();
      }
    } catch (_) {
      // Cae al fallback local.
    }

    return (recomendacionesFallback[claseId] ?? [])
        .map((r) => RecomendacionModel(
              id: r.id,
              enfermedad: r.enfermedad,
              orden: r.orden,
              titulo: r.titulo,
              descripcion: r.descripcion,
            ))
        .toList();
  }
}
