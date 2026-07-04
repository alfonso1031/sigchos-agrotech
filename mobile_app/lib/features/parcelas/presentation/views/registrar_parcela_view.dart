import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gps_preview_card.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/parcela_viewmodel.dart';

/// Paso 1 de 2 del alta de cultivo: Finca -> Parcela -> Cultivo.
class RegistrarParcelaView extends StatefulWidget {
  final String fincaId;
  const RegistrarParcelaView({super.key, required this.fincaId});

  @override
  State<RegistrarParcelaView> createState() => _RegistrarParcelaViewState();
}

class _RegistrarParcelaViewState extends State<RegistrarParcelaView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _capturarUbicacion() async {
    final concedido = await solicitarPermisoConAviso(
      context,
      permiso: Permission.location,
      icono: Icons.location_on_outlined,
      titulo: 'Ubicación de la parcela',
      mensaje:
          'Sigchos Agrotech usa tu ubicación GPS para registrar dónde está '
          'la parcela dentro de la finca. Solo se usa al guardar el registro.',
    );
    if (concedido && mounted) context.read<ParcelaViewModel>().capturarGps();
  }

  Future<void> _continuar() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = context.read<AuthViewModel>().usuario!.uid;
    final vm = context.read<ParcelaViewModel>();
    final ok = await vm.crearParcela(
      fincaId: widget.fincaId,
      usuarioId: uid,
      nombre: _nombreController.text.trim(),
      areaHectareas: double.parse(_areaController.text.trim()),
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.registrarCultivo,
        arguments: vm.ultimaParcelaId,
      );
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ParcelaViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    AppBackButton(onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registrar parcela',
                            style: AppTheme.displayFont(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Paso 1 de 2',
                            style: AppTheme.bodyFont(
                                fontSize: 12, color: AppColors.textoSecundario)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    AppTextField(
                      label: 'Nombre de la parcela',
                      controller: _nombreController,
                      validator: (v) =>
                          Validators.requerido(v, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Área (hectáreas)',
                      controller: _areaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          Validators.numeroPositivo(v, campo: 'El área'),
                    ),
                    const SizedBox(height: 16),
                    Text('UBICACIÓN GPS',
                        style: AppTheme.monoFont(fontSize: 11)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 7),
                    GpsPreviewCard(
                      lat: vm.gpsLat,
                      lng: vm.gpsLng,
                      cargando: vm.isGuardando && vm.gpsLat == null,
                      onCapturar: _capturarUbicacion,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppPrimaryButton(
                  label: 'Continuar',
                  loading: vm.isGuardando,
                  onPressed: _continuar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
