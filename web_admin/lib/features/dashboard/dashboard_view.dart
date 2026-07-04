import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enfermedades.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/viewmodels/admin_data_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDataViewModel>();
    final chart = vm.chartDiario();
    final maxTotal = chart
        .map((d) => d.sanas + d.enfermas)
        .fold(1, (a, b) => a > b ? a : b);
    final distribucion = vm.distribucionPorClase;
    final totalDistribucion = distribucion.values.fold(0, (a, b) => a + b);
    final recientes = vm.diagnosticos.take(6).toList();
    final alertas = vm.alertasDeZona();

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Row(
          children: [
            Expanded(
              child: _Kpi(
                titulo: 'Diagnósticos totales',
                valor: '${vm.totalDiagnosticos}',
                icono: Icons.eco_outlined,
                color: AppColors.verdeMedio,
                colorFondo: AppColors.sanoBg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Kpi(
                titulo: 'Hojas enfermas',
                valor: '${(vm.porcentajeEnfermas * 100).round()}%',
                icono: Icons.warning_amber_outlined,
                color: AppColors.severidadAlta,
                colorFondo: AppColors.severidadAltaBg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Kpi(
                titulo: 'Agricultores activos',
                valor: '${vm.agricultoresActivos}',
                icono: Icons.people_outline,
                color: const Color(0xFFB5731C),
                colorFondo: const Color(0xFFFCEFD9),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Kpi(
                titulo: 'Confianza media IA',
                valor: '${(vm.confianzaMedia * 100).toStringAsFixed(1)}%',
                icono: Icons.insights_outlined,
                color: AppColors.verdeMedio,
                colorFondo: const Color(0xFFE8EFE2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 155,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Diagnósticos por día',
                                  style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text('Últimos 14 días',
                                  style: AppTheme.body(fontSize: 12, color: AppColors.textoSecundario)),
                            ],
                          ),
                          Row(
                            children: [
                              _leyenda('Sanas', AppColors.sano),
                              const SizedBox(width: 14),
                              _leyenda('Enfermas', AppColors.severidadAlta),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 188,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final d in chart)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: (d.sanas / maxTotal) * 160,
                                        decoration: const BoxDecoration(
                                          color: AppColors.sano,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        height: (d.enfermas / maxTotal) * 160,
                                        decoration: const BoxDecoration(
                                          color: AppColors.severidadAlta,
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(DateFormat('d').format(d.dia),
                                          style: AppTheme.mono(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 100,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distribución por clase',
                          style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('6 clases foliares de zapallo',
                          style: AppTheme.body(fontSize: 12, color: AppColors.textoSecundario)),
                      const SizedBox(height: 18),
                      for (final claseId in nombreEnfermedad.keys)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.colorEnfermedad(claseId),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(nombreDe(claseId), style: AppTheme.body(fontSize: 13)),
                                    ],
                                  ),
                                  Text('${distribucion[claseId] ?? 0}', style: AppTheme.mono(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: totalDistribucion == 0
                                      ? 0
                                      : (distribucion[claseId] ?? 0) / totalDistribucion,
                                  minHeight: 7,
                                  backgroundColor: AppColors.divider,
                                  valueColor:
                                      AlwaysStoppedAnimation(AppColors.colorEnfermedad(claseId)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 155,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnósticos recientes',
                          style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      if (recientes.isEmpty)
                        Text('Sin diagnósticos registrados aún',
                            style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario))
                      else
                        for (final r in recientes)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(r.agricultor, style: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w500)),
                                ),
                                Expanded(
                                  child: Text(r.parcela,
                                      style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.fondoResultado(r.doc.enfermedad),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(nombreDe(r.doc.enfermedad),
                                        style: AppTheme.body(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.colorEnfermedad(r.doc.enfermedad))),
                                  ),
                                ),
                                Text('${(r.doc.confianza * 100).round()}%', style: AppTheme.mono(fontSize: 12)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 100,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alertas de zona',
                          style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      if (alertas.isEmpty)
                        Text('Sin focos activos en los últimos 7 días',
                            style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario))
                      else
                        for (final a in alertas)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: AppColors.fondoResultado(a.enfermedad),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 18, color: AppColors.colorEnfermedad(a.enfermedad)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.parcela,
                                          style: AppTheme.body(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.colorEnfermedad(a.enfermedad))),
                                      Text('${nombreDe(a.enfermedad)} · ${a.casos} casos en 7 días',
                                          style: AppTheme.body(fontSize: 12, color: AppColors.textoSecundario)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _leyenda(String label, Color color) {
    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.body(fontSize: 12, color: AppColors.textoSecundario)),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final Color colorFondo;

  const _Kpi({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(titulo, style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Icon(icono, size: 17, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(valor, style: AppTheme.display(fontSize: 30, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
