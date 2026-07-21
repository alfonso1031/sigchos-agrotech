import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../viewmodels/chat_diagnostico_viewmodel.dart';
import '../widgets/chat_bubble.dart';

class ChatDiagnosticoView extends StatefulWidget {
  final DiagnosticoEntity diagnostico;
  const ChatDiagnosticoView({super.key, required this.diagnostico});

  @override
  State<ChatDiagnosticoView> createState() => _ChatDiagnosticoViewState();
}

class _ChatDiagnosticoViewState extends State<ChatDiagnosticoView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatDiagnosticoViewModel>().iniciar(widget.diagnostico);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar() async {
    final texto = _controller.text;
    if (texto.trim().isEmpty) return;
    _controller.clear();
    await context.read<ChatDiagnosticoViewModel>().enviarMensaje(texto);
    _scrollAlFinal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Pregunta a la IA',
                        style: AppTheme.displayFont(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ChatDiagnosticoViewModel>(
                builder: (context, vm, _) {
                  _scrollAlFinal();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: vm.mensajes.length + (vm.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= vm.mensajes.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return ChatBubble(mensaje: vm.mensajes[index]);
                    },
                  );
                },
              ),
            ),
            Consumer<ChatDiagnosticoViewModel>(
              builder: (context, vm, _) => vm.errorMessage == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(vm.errorMessage!,
                          style: AppTheme.bodyFont(
                              fontSize: 12, color: Colors.red)),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<ChatDiagnosticoViewModel>(
                    builder: (context, vm, _) => SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.filled(
                        onPressed: vm.isLoading ? null : _enviar,
                        icon: const Icon(Icons.send, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
