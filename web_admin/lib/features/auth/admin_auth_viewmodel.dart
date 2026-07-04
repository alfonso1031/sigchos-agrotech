import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/admin_repository.dart';

/// Autentica con Firebase Auth y exige que el UID exista en la colección
/// `admins` — un agricultor con cuenta válida no puede entrar al panel.
class AdminAuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;
  final AdminRepository _adminRepository;

  AdminAuthViewModel({FirebaseAuth? auth, AdminRepository? adminRepository})
      : _auth = auth ?? FirebaseAuth.instance,
        _adminRepository = adminRepository ?? AdminRepository();

  User? usuario;
  String? nombreAdmin;
  bool isLoading = false;
  String? errorMessage;

  bool get autenticado => usuario != null;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final esAdmin = await _adminRepository.esAdmin(uid);
      if (!esAdmin) {
        await _auth.signOut();
        errorMessage = 'Esta cuenta no tiene permisos de administrador.';
        return false;
      }
      usuario = credential.user;
      nombreAdmin = usuario?.email?.split('@').first ?? 'Administrador';
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = switch (e.code) {
        'user-not-found' => 'No existe una cuenta con ese correo.',
        'wrong-password' || 'invalid-credential' => 'Correo o contraseña incorrectos.',
        'invalid-email' => 'El correo no es válido.',
        _ => 'Ocurrió un error al iniciar sesión.',
      };
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Inicio de sesión con Google (popup, propio de Flutter Web). Verifica que
  /// la cuenta esté en la colección `admins`; si no, cierra sesión y avisa.
  Future<bool> loginConGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      final uid = credential.user!.uid;
      final esAdmin = await _adminRepository.esAdmin(uid);
      if (!esAdmin) {
        await _auth.signOut();
        errorMessage =
            'La cuenta ${credential.user?.email} no tiene permisos de administrador.';
        return false;
      }
      usuario = credential.user;
      nombreAdmin = usuario?.displayName ??
          usuario?.email?.split('@').first ??
          'Administrador';
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code == 'popup-closed-by-user'
          ? null
          : 'No se pudo iniciar sesión con Google.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    usuario = null;
    notifyListeners();
  }
}
