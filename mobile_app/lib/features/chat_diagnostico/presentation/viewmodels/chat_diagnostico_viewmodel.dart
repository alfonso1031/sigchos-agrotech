import 'package:flutter/foundation.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/errors/failure.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/enviar_mensaje_chat_usecase.dart';
import '../../domain/usecases/iniciar_chat_usecase.dart';

/// Chat con IA (Gemini) acotado al diagnóstico que el usuario está viendo.
class ChatDiagnosticoViewModel extends ChangeNotifier {
  final IniciarChatUseCase _iniciarChatUseCase;
  final EnviarMensajeChatUseCase _enviarMensajeChatUseCase;

  ChatDiagnosticoViewModel({
    required IniciarChatUseCase iniciarChatUseCase,
    required EnviarMensajeChatUseCase enviarMensajeChatUseCase,
  })  : _iniciarChatUseCase = iniciarChatUseCase,
        _enviarMensajeChatUseCase = enviarMensajeChatUseCase;

  final List<ChatMessageEntity> mensajes = [];
  bool isLoading = false;
  String? errorMessage;

  void iniciar(DiagnosticoEntity diagnostico) {
    if (mensajes.isNotEmpty) return; // ya iniciado (p. ej. rebuild de la vista)
    final info = infoDe(diagnostico.enfermedad);
    final contexto = '''
Eres un asistente agrícola experto en sanidad vegetal. El usuario acaba de
recibir este diagnóstico automático de una hoja de su cultivo:

- Enfermedad/estado detectado: ${info.nombre} (${info.nombreCientifico})
- Descripción: ${info.descripcion}
- Síntomas típicos: ${info.sintomas}
- Confianza del modelo: ${(diagnostico.confianza * 100).round()}%

Responde en español, de forma breve y práctica, a las preguntas del usuario
sobre este diagnóstico (causas, tratamiento, prevención, cuidados del cultivo).
Si la pregunta no tiene relación con el diagnóstico o la agricultura, indícalo
amablemente y redirige la conversación. No inventes datos que no tengas.
''';
    _iniciarChatUseCase(contexto);
    mensajes.add(ChatMessageEntity(
      texto:
          'Hola, puedo ayudarte con preguntas sobre este diagnóstico (${info.nombre}). ¿Qué quieres saber?',
      esUsuario: false,
      fecha: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty || isLoading) return;
    errorMessage = null;
    mensajes.add(ChatMessageEntity(
      texto: texto.trim(),
      esUsuario: true,
      fecha: DateTime.now(),
    ));
    isLoading = true;
    notifyListeners();
    try {
      final respuesta = await _enviarMensajeChatUseCase(texto.trim());
      mensajes.add(ChatMessageEntity(
        texto: respuesta,
        esUsuario: false,
        fecha: DateTime.now(),
      ));
    } on Failure catch (f) {
      errorMessage = f.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
