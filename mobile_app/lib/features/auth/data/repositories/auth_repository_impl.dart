import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failure.dart';
import '../../../../services/storage_service.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource dataSource;
  final StorageService storageService;
  AuthRepositoryImpl(this.dataSource, {StorageService? storageService})
      : storageService = storageService ?? StorageService();

  @override
  Future<UsuarioEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.login(email, password);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mensajeError(e.code));
    }
  }

  @override
  Future<UsuarioEntity> loginConGoogle() async {
    try {
      return await dataSource.loginConGoogle();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mensajeError(e.code));
    } catch (e) {
      throw const AuthFailure('No se pudo iniciar sesión con Google.');
    }
  }

  @override
  Future<UsuarioEntity> register({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.register(
        nombre: nombre,
        cedula: cedula,
        telefono: telefono,
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mensajeError(e.code));
    }
  }

  @override
  Future<UsuarioEntity> actualizarPerfil({
    required String uid,
    required String nombre,
    required String cedula,
    required String telefono,
    String? nuevaFotoPath,
  }) async {
    try {
      // La subida de la foto es tolerante a fallo: si Storage no está activo,
      // se actualizan igual los demás datos sin cambiar la foto.
      String? fotoUrl;
      if (nuevaFotoPath != null) {
        try {
          fotoUrl = await storageService.subirFotoPerfil(
            File(nuevaFotoPath),
            uid,
          );
        } catch (_) {
          fotoUrl = null;
        }
      }
      return await dataSource.actualizarPerfil(
        uid: uid,
        nombre: nombre,
        cedula: cedula,
        telefono: telefono,
        fotoUrl: fotoUrl,
      );
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'No se pudo actualizar el perfil.');
    }
  }

  @override
  Future<void> logout() => dataSource.logout();

  @override
  Future<UsuarioEntity?> usuarioActual() async {
    try {
      return await dataSource.usuarioActual();
    } on fb.FirebaseAuthException {
      // Sesión de Firebase Auth activa pero sin perfil en Firestore
      // (estado corrupto): se trata como no autenticado.
      return null;
    }
  }

  @override
  Stream<UsuarioEntity?> get authStateChanges => dataSource.authStateChanges;

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'perfil-no-encontrado':
        return 'No se encontró el perfil del agricultor.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'cancelado-por-usuario':
        return 'Inicio de sesión con Google cancelado.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método.';
      default:
        return 'Ocurrió un error de autenticación. Intenta de nuevo.';
    }
  }
}
