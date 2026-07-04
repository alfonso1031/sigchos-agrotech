import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Sube imágenes de hojas a Firebase Storage.
/// Requiere el plan Blaze del proyecto Firebase — ver PLAN.md sección 7.6.
class StorageService {
  final FirebaseStorage _storage;
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> subirImagenHoja(File imagen, String usuarioId) async {
    final nombre =
        '${DateTime.now().millisecondsSinceEpoch}_${usuarioId.substring(0, 6)}.jpg';
    final ref = _storage.ref().child('diagnosticos/$usuarioId/$nombre');
    final task = await ref.putFile(imagen);
    return task.ref.getDownloadURL();
  }

  /// Sube/reemplaza la foto de perfil (siempre el mismo path, sobrescribe).
  Future<String> subirFotoPerfil(File imagen, String usuarioId) async {
    final ref = _storage.ref().child('perfiles/$usuarioId/avatar.jpg');
    final task = await ref.putFile(imagen);
    return task.ref.getDownloadURL();
  }
}
