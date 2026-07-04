import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class LoginGoogleUseCase {
  final AuthRepository repository;
  const LoginGoogleUseCase(this.repository);

  Future<UsuarioEntity> call() => repository.loginConGoogle();
}
