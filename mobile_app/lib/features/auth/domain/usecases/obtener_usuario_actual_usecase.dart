import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class ObtenerUsuarioActualUseCase {
  final AuthRepository repository;
  const ObtenerUsuarioActualUseCase(this.repository);

  Future<UsuarioEntity?> call() => repository.usuarioActual();
}
