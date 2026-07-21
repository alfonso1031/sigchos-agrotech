import '../repositories/chat_repository.dart';

class EnviarMensajeChatUseCase {
  final ChatRepository repository;
  const EnviarMensajeChatUseCase(this.repository);

  Future<String> call(String mensaje) => repository.enviarMensaje(mensaje);
}
