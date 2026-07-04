import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<UsuarioEntity> call({
    required String nombre,
    required String cedula,
    required String telefono,
    required String email,
    required String password,
  }) {
    return repository.register(
      nombre: nombre,
      cedula: cedula,
      telefono: telefono,
      email: email,
      password: password,
    );
  }
}
