import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/viewmodels/admin_data_viewmodel.dart';

class AgricultoresView extends StatelessWidget {
  const AgricultoresView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDataViewModel>();
    final agricultores = vm.agricultores;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cabecera(),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: agricultores.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('Sin agricultores registrados aún',
                          style: AppTheme.body(
                              fontSize: 13, color: AppColors.textoSecundario)),
                    )
                  : ListView.builder(
                      itemCount: agricultores.length,
                      itemBuilder: (context, i) => _fila(agricultores[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(AgricultorResumen a) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F0E8))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF2EFE6),
                  child: Text(
                    a.usuario.nombre.isNotEmpty ? a.usuario.nombre[0].toUpperCase() : '?',
                    style: AppTheme.display(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textoSecundario),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.usuario.nombre,
                          style: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(a.usuario.correo,
                          style: AppTheme.body(fontSize: 11, color: AppColors.textoDeshabilitado)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 13,
            child: Text(a.finca, style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
          ),
          Expanded(
            flex: 10,
            child: Text('${a.parcelas}', style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
          ),
          Expanded(
            flex: 8,
            child: Text('${a.diagnosticos}', textAlign: TextAlign.center, style: AppTheme.mono(fontSize: 13)),
          ),
          Expanded(
            flex: 10,
            child: Text(
              a.ultimoDiagnostico == null
                  ? '—'
                  : DateFormat('dd MMM · HH:mm', 'es').format(a.ultimoDiagnostico!),
              style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecera() {
    final style = AppTheme.mono(fontSize: 10, color: AppColors.textoDeshabilitado).copyWith(letterSpacing: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(flex: 16, child: Text('AGRICULTOR', style: style)),
          Expanded(flex: 13, child: Text('FINCA', style: style)),
          Expanded(flex: 10, child: Text('PARCELAS', style: style)),
          Expanded(flex: 8, child: Text('DIAGNÓSTICOS', textAlign: TextAlign.center, style: style)),
          Expanded(flex: 10, child: Text('ÚLTIMO ACCESO', style: style)),
        ],
      ),
    );
  }
}
