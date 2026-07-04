import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_tab_bar.dart';
import '../../../clima/presentation/viewmodels/clima_viewmodel.dart';
import '../../../fincas/presentation/viewmodels/finca_viewmodel.dart';
import '../../../historial/presentation/viewmodels/historial_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Pantalla "Inicio" — home/dashboard del agricultor (sección isInicio del
/// prototipo). Agrega datos reales de clima, finca principal e historial.
class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().usuario?.uid;
      if (uid == null) return;
      context.read<FincaViewModel>().escucharFincas(uid);
      context.read<HistorialViewModel>().escuchar(uid);
      if (context.read<ClimaViewModel>().actual == null) {
        context.read<ClimaViewModel>().cargar();
      }
    });
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días,';
    if (hora < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().usuario;
    final clima = context.watch<ClimaViewModel>();
    final fincaVm = context.watch<FincaViewModel>();
    final historialVm = context.watch<HistorialViewModel>();

    final finca = fincaVm.fincaPrincipal;
    final recientes = historialVm.diagnosticos.take(2).toList();
    final conDanoRecientes = historialVm.diagnosticos
        .where((d) =>
            d.enfermedad != 'hoja_sana' &&
            DateTime.now().difference(d.fecha).inDays <= 7)
        .length;

    return Scaffold(
      bottomNavigationBar: const MainTabBar(current: TabItem.inicio),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              decoration: const BoxDecoration(
                color: AppColors.verdeOscuro,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.perfil),
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_saludo(),
                                  style: AppTheme.bodyFont(
                                      fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                              Text(usuario?.nombre.split(' ').take(2).join(' ') ?? '',
                                  style: AppTheme.displayFont(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.clima),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wb_cloudy_outlined,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    clima.actual != null
                                        ? '${clima.actual!.temperatura.round()}°'
                                        : '--°',
                                    style: AppTheme.bodyFont(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    clima.actual?.ciudad ?? 'Sigchos',
                                    style: AppTheme.bodyFont(
                                        fontSize: 10, color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (finca != null)
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.fincas),
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.naranja,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.landscape_outlined,
                                  color: Colors.white, size: 17),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(finca.nombre,
                                      style: AppTheme.bodyFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  Text(finca.direccion,
                                      style: AppTheme.bodyFont(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.66))),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.white.withValues(alpha: 0.6)),
                          ],
                        ),
                      ),
                    )
                  else if (!fincaVm.isLoading)
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.fincas),
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Registra tu primera finca',
                                  style: AppTheme.bodyFont(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.white.withValues(alpha: 0.6)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.captura,
                      arguments: null,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradienteCTA,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 27),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nuevo diagnóstico',
                                    style: AppTheme.displayFont(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                Text('Captura una hoja y analiza con IA',
                                    style: AppTheme.bodyFont(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.82))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Últimos diagnósticos',
                            style: AppTheme.displayFont(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        InkWell(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.historial),
                          child: Text('Ver todo',
                              style: AppTheme.bodyFont(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.verdeMedio)),
                        ),
                      ],
                    ),
                  ),
                  if (recientes.isEmpty)
                    Text('Aún no tienes diagnósticos registrados',
                        style: AppTheme.bodyFont(
                            fontSize: 13, color: AppColors.textoSecundario))
                  else
                    for (final d in recientes)
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.diagnostico,
                          arguments: d,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.fondoEnfermedad(d.enfermedad),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.eco_outlined,
                                    color: AppColors.colorEnfermedad(d.enfermedad)),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(infoDe(d.enfermedad).nombre,
                                        style: AppTheme.bodyFont(
                                            fontSize: 15, fontWeight: FontWeight.w600)),
                                    Text(
                                      DateFormat('dd MMM · HH:mm', 'es').format(d.fecha),
                                      style: AppTheme.bodyFont(
                                          fontSize: 12, color: AppColors.textoSecundario),
                                    ),
                                  ],
                                ),
                              ),
                              Text('${(d.confianza * 100).round()}%',
                                  style: AppTheme.monoFont(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.colorEnfermedad(d.enfermedad))),
                            ],
                          ),
                        ),
                      ),
                  if (conDanoRecientes > 0 ||
                      (clima.actual?.riesgoFungicoAlto ?? false))
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.mapa),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.alertaFondo,
                          border: Border.all(color: AppColors.alertaBorde),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.alertaTexto),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Alerta de zona',
                                      style: AppTheme.bodyFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.alertaTexto)),
                                  Text(
                                    conDanoRecientes > 0
                                        ? '$conDanoRecientes diagnósticos con daño esta semana'
                                        : 'Condiciones favorables a hongos foliares',
                                    style: AppTheme.bodyFont(
                                        fontSize: 12,
                                        color: const Color(0xFFA07636)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.naranja),
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
    );
  }
}
