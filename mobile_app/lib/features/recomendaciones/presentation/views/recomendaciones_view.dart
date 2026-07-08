import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../viewmodels/recomendacion_viewmodel.dart';

class RecomendacionesView extends StatefulWidget {
  final DiagnosticoEntity diagnostico;
  const RecomendacionesView({super.key, required this.diagnostico});

  @override
  State<RecomendacionesView> createState() => _RecomendacionesViewState();
}

class _RecomendacionesViewState extends State<RecomendacionesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecomendacionViewModel>().cargar(widget.diagnostico.enfermedad);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecomendacionViewModel>();
    final info = infoDe(widget.diagnostico.enfermedad);
    final esSana = widget.diagnostico.enfermedad == 'hoja_sana';
    final clima = widget.diagnostico.clima;

    final alerta = esSana
        ? 'Hoja sin signos de enfermedad. Mantén el monitoreo preventivo cada 3–4 días.'
        : clima != null
            ? 'Clima favorable al patógeno: humedad ${clima.humedad}% y ${clima.descripcion.toLowerCase()}. Actúa en las próximas 48 h.'
            : 'Actúa cuanto antes: la propagación es más rápida con humedad alta.';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recomendaciones',
                          style: AppTheme.displayFont(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Text(info.nombre,
                          style: AppTheme.bodyFont(
                              fontSize: 12, color: AppColors.textoSecundario)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.sanoBg,
                            border: Border.all(color: const Color(0xFFC7E0CC)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.eco_outlined,
                                  color: Color(0xFF2C5A3C), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  alerta,
                                  style: AppTheme.bodyFont(
                                      fontSize: 13,
                                      color: const Color(0xFF2C5A3C),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final r in vm.recomendaciones)
                          Container(
                            margin: const EdgeInsets.only(bottom: 11),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCEFD9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${r.orden}',
                                      style: AppTheme.displayFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFB5731C))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.titulo,
                                          style: AppTheme.bodyFont(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 3),
                                      Text(r.descripcion,
                                          style: AppTheme.bodyFont(
                                              fontSize: 13,
                                              color: AppColors.textoSecundario)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeOscuro,
                  ),
                  child: const Text('Listo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
