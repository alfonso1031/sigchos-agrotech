import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/viewmodels/admin_data_viewmodel.dart';
import '../../core/widgets/admin_sidebar.dart';
import '../agricultores/agricultores_view.dart';
import '../auth/admin_auth_viewmodel.dart';
import '../dashboard/dashboard_view.dart';
import '../diagnosticos/diagnosticos_view.dart';
import '../modelo_ia/modelo_ia_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection _section = AdminSection.resumen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDataViewModel>().cargar();
    });
  }

  (String, String) get _titulo => switch (_section) {
        AdminSection.resumen => ('Resumen general', 'Monitoreo de diagnósticos foliares · cantón Sigchos'),
        AdminSection.diagnosticos => ('Diagnósticos', 'Análisis de hoja registrados en Firestore'),
        AdminSection.agricultores => ('Agricultores', 'Cuentas activas en la plataforma'),
        AdminSection.modeloIa => ('Modelo IA', 'Rendimiento del clasificador TensorFlow Lite'),
      };

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AdminAuthViewModel>();
    final dataVm = context.watch<AdminDataViewModel>();
    final (titulo, subtitulo) = _titulo;

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            current: _section,
            totalDiagnosticos: dataVm.totalDiagnosticos,
            nombreAdmin: authVm.nombreAdmin ?? 'Administrador',
            onNavegar: (s) => setState(() => _section = s),
            onLogout: () => context.read<AdminAuthViewModel>().logout(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 30, 36, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: AppTheme.display(fontSize: 27, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(subtitulo, style: AppTheme.body(fontSize: 14, color: AppColors.textoSecundario)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.cardBorder),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textoSecundario),
                                const SizedBox(width: 8),
                                Text(DateFormat('d \'de\' MMMM, yyyy', 'es').format(DateTime.now()),
                                    style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: dataVm.isLoading ? null : () => dataVm.cargar(),
                            tooltip: 'Actualizar datos',
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: dataVm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : dataVm.errorMessage != null
                            ? Center(child: Text(dataVm.errorMessage!))
                            : switch (_section) {
                                AdminSection.resumen => const DashboardView(),
                                AdminSection.diagnosticos => const DiagnosticosView(),
                                AdminSection.agricultores => const AgricultoresView(),
                                AdminSection.modeloIa => const ModeloIaView(),
                              },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
