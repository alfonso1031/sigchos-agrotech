import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class ActualizarPerfilUseCase {
  final AuthRepository repository;
  const ActualizarPerfilUseCase(this.repository);

  Future<UsuarioEntity> call({
    required String uid,
    required String nombre,
    required String cedula,
    required String telefono,
    String? nuevaFotoPath,
  }) {
    return repository.actualizarPerfil(
      uid: uid,
      nombre: nombre,
      cedula: cedula,
      telefono: telefono,
      nuevaFotoPath: nuevaFotoPath,
    );
  }
}
