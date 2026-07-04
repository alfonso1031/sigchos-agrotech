class UsuarioEntity {
  final String uid;
  final String nombre;
  final String cedula;
  final String telefono;
  final String email;
  final String? fotoUrl;
  final DateTime fechaRegistro;

  const UsuarioEntity({
    required this.uid,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.email,
    required this.fechaRegistro,
    this.fotoUrl,
  });
}
