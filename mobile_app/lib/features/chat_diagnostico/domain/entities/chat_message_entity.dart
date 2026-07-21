class ChatMessageEntity {
  final String texto;
  final bool esUsuario;
  final DateTime fecha;

  const ChatMessageEntity({
    required this.texto,
    required this.esUsuario,
    required this.fecha,
  });
}
