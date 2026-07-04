import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gps_preview_card.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/finca_entity.dart';
import '../viewmodels/finca_viewmodel.dart';

/// Crea una finca nueva, o edita una existente si se pasa [fincaEditar].
class RegistrarFincaView extends StatefulWidget {
  final FincaEntity? fincaEditar;
  const RegistrarFincaView({super.key, this.fincaEditar});

  @override
  State<RegistrarFincaView> createState() => _RegistrarFincaViewState();
}

class _RegistrarFincaViewState extends State<RegistrarFincaView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _areaController = TextEditingController();

  bool get _esEdicion => widget.fincaEditar != null;

  @override
  void initState() {
    super.initState();
    // Limpia el GPS del ViewModel para no arrastrar coordenadas anteriores.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FincaViewModel>().limpiarGps();
    });
    final f = widget.fincaEditar;
    if (f != null) {
      _nombreController.text = f.nombre;
      _direccionController.text = f.direccion;
      _areaController.text = f.areaHectareas.toString();
    }
  }

  Future<void> _capturarUbicacion() async {
    final concedido = await solicitarPermisoConAviso(
      context,
      permiso: Permission.location,
      icono: Icons.location_on_outlined,
      titulo: 'Ubicación de la finca',
      mensaje:
          'Sigchos Agrotech usa tu ubicación GPS para registrar dónde está '
          'la finca y mostrarla en el mapa de incidencia.',
    );
    if (concedido && mounted) context.read<FincaViewModel>().capturarGps();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<FincaViewModel>();
    bool ok;
    if (_esEdicion) {
      ok = await vm.actualizarFinca(
        original: widget.fincaEditar!,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        areaHectareas: double.parse(_areaController.text.trim()),
        nuevaUbicacion: vm.gpsLat != null,
      );
    } else {
      final uid = context.read<AuthViewModel>().usuario!.uid;
      ok = await vm.crearFinca(
        usuarioId: uid,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        areaHectareas: double.parse(_areaController.text.trim()),
      );
    }
    if (ok && mounted) {
      Navigator.of(context).pop();
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FincaViewModel>();
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
                    Text(_esEdicion ? 'Editar finca' : 'Registrar finca',
                        style: AppTheme.displayFont(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    AppTextField(
                      label: 'Nombre de la finca',
                      controller: _nombreController,
                      validator: (v) =>
                          Validators.requerido(v, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Sector / dirección',
                      controller: _direccionController,
                      validator: (v) =>
                          Validators.requerido(v, campo: 'La dirección'),
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
                    Text(
                      _esEdicion ? 'ACTUALIZAR UBICACIÓN GPS (OPCIONAL)' : 'UBICACIÓN GPS',
                      style: AppTheme.monoFont(fontSize: 11)
                          .copyWith(letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 7),
                    GpsPreviewCard(
                      lat: vm.gpsLat,
                      lng: vm.gpsLng,
                      cargando: vm.isCapturandoGps,
                      onCapturar: _capturarUbicacion,
                    ),
                    if (_esEdicion && vm.gpsLat == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Se conservará la ubicación actual si no capturas una nueva.',
                          style: AppTheme.bodyFont(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppPrimaryButton(
                  label: _esEdicion ? 'Guardar cambios' : 'Guardar finca',
                  loading: vm.isGuardando,
                  onPressed: _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
