import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_keys.dart';

/// Cliente de Gemini (https://ai.google.dev) para el chat sobre un diagnóstico.
/// Mantiene la sesión de chat en memoria mientras la vista esté abierta.
class GeminiChatDataSource {
  static const _modelo = 'gemini-2.0-flash';

  ChatSession? _chat;

  void iniciarChat(String contextoSistema) {
    final model = GenerativeModel(
      model: _modelo,
      apiKey: ApiKeys.geminiApiKey,
      systemInstruction: Content.system(contextoSistema),
    );
    _chat = model.startChat();
  }

  Future<String> enviarMensaje(String mensaje) async {
    final chat = _chat;
    if (chat == null) {
      throw Exception('El chat no se inició.');
    }
    final respuesta = await chat.sendMessage(Content.text(mensaje));
    final texto = respuesta.text;
    if (texto == null || texto.isEmpty) {
      throw Exception('La IA no devolvió respuesta.');
    }
    return texto;
  }
}
