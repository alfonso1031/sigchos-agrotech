import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';
import '../models/admin_models.dart';

/// Único punto de acceso a Firestore para todo el panel admin. Al ser un
/// panel de solo lectura/monitoreo, se centraliza aquí en vez de replicar
/// la separación domain/data/presentation completa de la app móvil.
class AdminRepository {
  final FirebaseFirestore _firestore;
  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> esAdmin(String uid) async {
    final doc =
        await _firestore.collection(FirestorePaths.admins).doc(uid).get();
    return doc.exists;
  }

  Future<List<UsuarioDoc>> obtenerUsuarios() async {
    final snap = await _firestore.collection(FirestorePaths.usuarios).get();
    return snap.docs.map(UsuarioDoc.fromDoc).toList();
  }

  Future<List<FincaDoc>> obtenerFincas() async {
    final snap = await _firestore.collection(FirestorePaths.fincas).get();
    return snap.docs.map(FincaDoc.fromDoc).toList();
  }

  Future<List<ParcelaDoc>> obtenerParcelas() async {
    final snap = await _firestore.collection(FirestorePaths.parcelas).get();
    return snap.docs.map(ParcelaDoc.fromDoc).toList();
  }

  Future<List<CultivoDoc>> obtenerCultivos() async {
    final snap = await _firestore.collection(FirestorePaths.cultivos).get();
    return snap.docs.map(CultivoDoc.fromDoc).toList();
  }

  Future<List<DiagnosticoDoc>> obtenerDiagnosticos() async {
    final snap = await _firestore
        .collection(FirestorePaths.diagnosticosHojas)
        .orderBy('fecha', descending: true)
        .get();
    return snap.docs.map(DiagnosticoDoc.fromDoc).toList();
  }
}
