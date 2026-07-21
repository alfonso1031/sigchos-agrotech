/// Contrato del chat con IA sobre un diagnóstico. La implementación mantiene
/// la sesión (historial) internamente entre llamadas a [enviarMensaje].
abstract class ChatRepository {
  void iniciarChat(String contextoSistema);
  Future<String> enviarMensaje(String mensaje);
}
