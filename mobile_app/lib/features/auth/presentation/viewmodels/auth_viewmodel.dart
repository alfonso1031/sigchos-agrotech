import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/usecases/actualizar_perfil_usecase.dart';
import '../../domain/usecases/login_google_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/obtener_usuario_actual_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { desconocido, autenticando, autenticado, noAutenticado }

/// ViewModel del feature auth (patrón MVVM). Las vistas solo leen este estado
/// vía Provider/Consumer y disparan acciones; nunca llaman a Firebase directo.
class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LoginGoogleUseCase _loginGoogleUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ObtenerUsuarioActualUseCase _obtenerUsuarioActualUseCase;
  final ActualizarPerfilUseCase _actualizarPerfilUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required LoginGoogleUseCase loginGoogleUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required ObtenerUsuarioActualUseCase obtenerUsuarioActualUseCase,
    required ActualizarPerfilUseCase actualizarPerfilUseCase,
  })  : _loginUseCase = loginUseCase,
        _loginGoogleUseCase = loginGoogleUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _obtenerUsuarioActualUseCase = obtenerUsuarioActualUseCase,
        _actualizarPerfilUseCase = actualizarPerfilUseCase;

  /// Usado solo por el Splash para decidir la ruta inicial.
  Future<UsuarioEntity?> authStateChangesFuture() async {
    usuario = await _obtenerUsuarioActualUseCase();
    if (usuario != null) status = AuthStatus.autenticado;
    return usuario;
  }

  AuthStatus status = AuthStatus.desconocido;
  UsuarioEntity? usuario;
  String? errorMessage;
  bool isLoading = false;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      usuario = await _loginUseCase(email: email, password: password);
      status = AuthStatus.autenticado;
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      status = AuthStatus.noAutenticado;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Devuelve true si autenticó, false si canceló o falló.
  /// [necesitaCompletarPerfil] queda true cuando la cuenta Google es nueva y
  /// aún no tiene cédula/teléfono (para invitar a completar el perfil).
  bool necesitaCompletarPerfil = false;

  Future<bool> loginConGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      usuario = await _loginGoogleUseCase();
      necesitaCompletarPerfil =
          usuario!.cedula.isEmpty || usuario!.telefono.isEmpty;
      status = AuthStatus.autenticado;
      return true;
    } on Failure catch (f) {
      // "cancelado" no es un error real que valga mostrar como alarma.
      errorMessage =
          f.message.contains('cancelado') ? null : f.message;
      status = AuthStatus.noAutenticado;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      usuario = await _registerUseCase(
        nombre: nombre,
        cedula: cedula,
        telefono: telefono,
        email: email,
        password: password,
      );
      status = AuthStatus.autenticado;
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      status = AuthStatus.noAutenticado;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarPerfil({
    required String nombre,
    required String cedula,
    required String telefono,
    String? nuevaFotoPath,
  }) async {
    if (usuario == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      usuario = await _actualizarPerfilUseCase(
        uid: usuario!.uid,
        nombre: nombre,
        cedula: cedula,
        telefono: telefono,
        nuevaFotoPath: nuevaFotoPath,
      );
      necesitaCompletarPerfil =
          usuario!.cedula.isEmpty || usuario!.telefono.isEmpty;
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    usuario = null;
    status = AuthStatus.noAutenticado;
    necesitaCompletarPerfil = false;
    notifyListeners();
  }

  void limpiarError() {
    errorMessage = null;
    notifyListeners();
  }
}
