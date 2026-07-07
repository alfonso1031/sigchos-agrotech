import '../entities/usuario_entity.dart';

/// Contrato de autenticación. `data/repositories/auth_repository_impl.dart`
/// lo implementa contra Firebase; los casos de uso y ViewModels solo conocen
/// esta abstracción (regla de dependencias de Clean Architecture).
abstract class AuthRepository {
  Future<UsuarioEntity> login({
    required String email,
    required String password,
  });

  Future<UsuarioEntity> loginConGoogle();

  Future<UsuarioEntity> register({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
  });

  /// Actualiza los datos del agricultor. [nuevaFotoPath] (ruta local) es
  /// opcional; si se pasa, se sube a Storage y se guarda su URL.
  /// Devuelve el usuario actualizado y [fotoFallo] = true si la foto no se
  /// pudo subir (el resto de datos sí se guardó).
  Future<({UsuarioEntity usuario, bool fotoFallo})> actualizarPerfil({
    required String uid,
    required String nombre,
    required String cedula,
    required String telefono,
    String? nuevaFotoPath,
  });

  Future<void> logout();

  Future<UsuarioEntity?> usuarioActual();

  Stream<UsuarioEntity?> get authStateChanges;
}
