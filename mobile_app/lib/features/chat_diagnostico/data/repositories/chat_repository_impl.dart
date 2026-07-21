import '../../../../core/errors/failure.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiChatDataSource dataSource;
  const ChatRepositoryImpl(this.dataSource);

  @override
  void iniciarChat(String contextoSistema) {
    dataSource.iniciarChat(contextoSistema);
  }

  @override
  Future<String> enviarMensaje(String mensaje) async {
    try {
      return await dataSource.enviarMensaje(mensaje);
    } catch (e) {
      throw NetworkFailure(
          'No se pudo contactar a la IA. Revisa tu conexión o la API key.');
    }
  }
}
