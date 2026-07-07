import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enfermedades.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_tab_bar.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../viewmodels/historial_viewmodel.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().usuario?.uid;
      if (uid != null) context.read<HistorialViewModel>().escuchar(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialViewModel>();

    return Scaffold(
      bottomNavigationBar: const MainTabBar(current: TabItem.historial),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historial',
                      style: AppTheme.displayFont(
                          fontSize: 24, fontWeight: FontWeight.w700)),
                  Text('${vm.diagnosticos.length} diagnósticos',
                      style: AppTheme.bodyFont(
                          fontSize: 13, color: AppColors.textoSecundario)),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Chip(
                    label: 'Todos',
                    selected: vm.filtroClase == null,
                    onTap: () => vm.filtrarPor(null),
                  ),
                  for (final claseId in catalogoEnfermedades.keys)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _Chip(
                        label: infoDe(claseId).nombre,
                        selected: vm.filtroClase == claseId,
                        onTap: () => vm.filtrarPor(claseId),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.diagnosticos.isEmpty
                      ? Center(
                          child: Text('Aún no hay diagnósticos registrados',
                              style: AppTheme.bodyFont(
                                  fontSize: 14, color: AppColors.textoSecundario)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 96),
                          itemCount: vm.diagnosticos.length,
                          itemBuilder: (context, i) {
                            final d = vm.diagnosticos[i];
                            final info = infoDe(d.enfermedad);
                            final color = AppColors.colorEnfermedad(d.enfermedad);
                            return Dismissible(
                              key: ValueKey(d.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) =>
                                  _confirmarEliminar(context, info.nombre),
                              onDismissed: (_) => _eliminar(context, vm, d),
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.only(right: 22),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: AppColors.severidadAlta,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white),
                              ),
                              child: InkWell(
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
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: d.imagenUrl.isNotEmpty
                                            ? Image.network(
                                                d.imagenUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (context, child, progress) =>
                                                        progress == null
                                                            ? child
                                                            : _thumbPlaceholder(),
                                                errorBuilder: (_, _, _) =>
                                                    _thumbPlaceholder(),
                                              )
                                            : _thumbPlaceholder(),
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(info.nombre,
                                              style: AppTheme.bodyFont(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            DateFormat('dd MMM · HH:mm', 'es')
                                                .format(d.fecha),
                                            style: AppTheme.bodyFont(
                                                fontSize: 12,
                                                color: AppColors.textoSecundario),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${(d.confianza * 100).round()}%',
                                            style: AppTheme.monoFont(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: color)),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                              color: color, shape: BoxShape.circle),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        color: AppColors.inputFill,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: AppColors.textoDeshabilitado),
      );

  Future<bool> _confirmarEliminar(BuildContext context, String nombre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar diagnóstico'),
        content: Text(
            '¿Eliminar el diagnóstico de "$nombre"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.severidadAlta),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _eliminar(
    BuildContext context,
    HistorialViewModel vm,
    DiagnosticoEntity d,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await vm.eliminar(d);
      messenger.showSnackBar(
        const SnackBar(content: Text('Diagnóstico eliminado')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.verdeOscuro : AppColors.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected ? AppColors.verdeOscuro : AppColors.cardBorder),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTheme.bodyFont(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textoSecundario,
            )),
      ),
    );
  }
}
