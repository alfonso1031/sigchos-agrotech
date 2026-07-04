import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../core/widgets/main_tab_bar.dart';
import '../viewmodels/clima_viewmodel.dart';

class ClimaView extends StatefulWidget {
  const ClimaView({super.key});

  @override
  State<ClimaView> createState() => _ClimaViewState();
}

class _ClimaViewState extends State<ClimaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarClima());
  }

  Future<void> _cargarClima() async {
    if (context.read<ClimaViewModel>().actual != null) return;
    final concedido = await solicitarPermisoConAviso(
      context,
      permiso: Permission.location,
      icono: Icons.wb_cloudy_outlined,
      titulo: 'Clima de tu ubicación',
      mensaje:
          'Sigchos Agrotech usa tu GPS para mostrarte el clima exacto de tu '
          'zona y avisarte si hay riesgo de hongos foliares.',
    );
    if (concedido && mounted) context.read<ClimaViewModel>().cargar();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClimaViewModel>();

    if (vm.isLoading && vm.actual == null) {
      return const Scaffold(
        bottomNavigationBar: MainTabBar(current: TabItem.clima),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.errorMessage != null && vm.actual == null) {
      return Scaffold(
        bottomNavigationBar: const MainTabBar(current: TabItem.clima),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 40, color: AppColors.textoDeshabilitado),
                const SizedBox(height: 12),
                Text(vm.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.cargar(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final actual = vm.actual!;
    return Scaffold(
      bottomNavigationBar: const MainTabBar(current: TabItem.clima),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Clima',
                      style: AppTheme.displayFont(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => vm.cargar(),
                    icon: const Icon(Icons.refresh, color: AppColors.textoSecundario),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ---- Card principal ----
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteClima,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.verdeOscuro.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(actual.ciudad,
                                style: AppTheme.bodyFont(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        ),
                        Text('Hoy',
                            style: AppTheme.bodyFont(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(_iconoClima(actual.descripcion),
                            color: Colors.white, size: 68),
                        const SizedBox(width: 12),
                        Text('${actual.temperatura.round()}°',
                            style: AppTheme.displayFont(
                                fontSize: 72,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                    Text(actual.descripcion,
                        style: AppTheme.bodyFont(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _statChip(Icons.water_drop_outlined, 'Humedad',
                            '${actual.humedad}%'),
                        const SizedBox(width: 10),
                        _statChip(Icons.umbrella_outlined, 'Lluvia',
                            '${actual.probabilidadLluvia}%'),
                        const SizedBox(width: 10),
                        _statChip(Icons.air, 'Viento',
                            '${actual.vientoKmh.round()} km/h'),
                      ],
                    ),
                  ],
                ),
              ),
              // ---- Alerta fúngica ----
              if (actual.riesgoFungicoAlto)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertaFondo,
                    border: Border.all(color: AppColors.alertaBorde),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.alertaBorde.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: AppColors.alertaTexto, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Riesgo fúngico alto',
                                style: AppTheme.displayFont(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.alertaTexto)),
                            const SizedBox(height: 3),
                            Text(
                              'La humedad y la lluvia favorecen la mancha foliar y el mildiú. Evita el riego por aspersión y revisa el envés de las hojas.',
                              style: AppTheme.bodyFont(
                                  fontSize: 13, color: AppColors.alertaTexto),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // ---- Próximos días ----
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
                child: Text('PRÓXIMOS DÍAS',
                    style: AppTheme.monoFont(fontSize: 11).copyWith(letterSpacing: 1)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < vm.pronostico.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: i < vm.pronostico.length - 1
                              ? const Border(bottom: BorderSide(color: Color(0xFFF3F0E8)))
                              : null,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 54,
                              child: Text(vm.pronostico[i].dia,
                                  style: AppTheme.bodyFont(
                                      fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                            Icon(_iconoClima(''),
                                size: 22, color: AppColors.textoSecundario),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B8FC9).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.water_drop,
                                      size: 12, color: Color(0xFF5B8FC9)),
                                  const SizedBox(width: 3),
                                  Text('${vm.pronostico[i].probabilidadLluvia}%',
                                      style: AppTheme.bodyFont(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF5B8FC9))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 88,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${vm.pronostico[i].tempMax.round()}°',
                                      style: AppTheme.monoFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textoPrimario)),
                                  Text('  /  ${vm.pronostico[i].tempMin.round()}°',
                                      style: AppTheme.monoFont(
                                          fontSize: 14,
                                          color: AppColors.textoDeshabilitado)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('datos · OpenWeather API',
                    style: AppTheme.monoFont(
                        fontSize: 10, color: AppColors.textoDeshabilitado)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconoClima(String descripcion) {
    final d = descripcion.toLowerCase();
    if (d.contains('torment') || d.contains('storm')) return Icons.thunderstorm;
    if (d.contains('lluvia') || d.contains('rain') || d.contains('llovizna')) {
      return Icons.grain;
    }
    if (d.contains('nieve') || d.contains('snow')) return Icons.ac_unit;
    if (d.contains('niebla') || d.contains('bruma') || d.contains('mist') ||
        d.contains('fog')) {
      return Icons.foggy;
    }
    if (d.contains('despejado') || d.contains('clear') || d.contains('sol')) {
      return Icons.wb_sunny;
    }
    return Icons.wb_cloudy;
  }

  Widget _statChip(IconData icono, String label, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icono, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(valor,
                style: AppTheme.bodyFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                style: AppTheme.bodyFont(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
