import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enfermedades.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/viewmodels/admin_data_viewmodel.dart';

class DiagnosticosView extends StatefulWidget {
  const DiagnosticosView({super.key});

  @override
  State<DiagnosticosView> createState() => _DiagnosticosViewState();
}

class _DiagnosticosViewState extends State<DiagnosticosView> {
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDataViewModel>();
    final todos = vm.diagnosticos;
    final filtrados = _filtro == null
        ? todos
        : todos.where((d) => d.doc.enfermedad == _filtro).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                _chip('Todos', _filtro == null, () => setState(() => _filtro = null)),
                for (final claseId in nombreEnfermedad.keys)
                  _chip(nombreDe(claseId), _filtro == claseId,
                      () => setState(() => _filtro = claseId)),
              ],
            ),
            const SizedBox(height: 16),
            _cabecera(),
            const Divider(height: 1, color: AppColors.divider),
            if (filtrados.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Sin diagnósticos para este filtro',
                    style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
              )
            else
              for (final r in filtrados)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF3F0E8))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(r.agricultor,
                            style: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 10,
                        child: Text(r.parcela,
                            style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                      ),
                      Expanded(
                        flex: 11,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.fondoResultado(r.doc.enfermedad),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(nombreDe(r.doc.enfermedad),
                                style: AppTheme.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.colorEnfermedad(r.doc.enfermedad))),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Text('${(r.doc.confianza * 100).round()}%',
                            textAlign: TextAlign.right, style: AppTheme.mono(fontSize: 13)),
                      ),
                      Expanded(
                        flex: 10,
                        child: Text(DateFormat('dd MMM · HH:mm', 'es').format(r.doc.fecha),
                            style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                      ),
                      Expanded(
                        flex: 7,
                        child: Icon(
                          r.doc.lat != null ? Icons.location_on_outlined : Icons.location_off_outlined,
                          size: 16,
                          color: AppColors.textoDeshabilitado,
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

  Widget _cabecera() {
    TextStyle style = AppTheme.mono(fontSize: 10, color: AppColors.textoDeshabilitado)
        .copyWith(letterSpacing: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(flex: 14, child: Text('AGRICULTOR', style: style)),
          Expanded(flex: 10, child: Text('PARCELA', style: style)),
          Expanded(flex: 11, child: Text('RESULTADO', style: style)),
          Expanded(flex: 9, child: Text('CONFIANZA', textAlign: TextAlign.right, style: style)),
          Expanded(flex: 10, child: Text('FECHA', style: style)),
          Expanded(flex: 7, child: Text('GPS', style: style)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.verdeOscuro : const Color(0xFFF6F4EE),
          border: Border.all(color: selected ? AppColors.verdeOscuro : AppColors.cardBorder),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: AppTheme.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textoSecundario,
            )),
      ),
    );
  }
}
