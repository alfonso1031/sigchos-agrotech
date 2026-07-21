import '../repositories/chat_repository.dart';

class IniciarChatUseCase {
  final ChatRepository repository;
  const IniciarChatUseCase(this.repository);

  void call(String contextoSistema) => repository.iniciarChat(contextoSistema);
}
