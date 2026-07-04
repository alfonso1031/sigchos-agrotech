import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../parcelas/domain/entities/parcela_entity.dart';
import '../../../parcelas/presentation/viewmodels/parcela_viewmodel.dart';
import '../../domain/entities/finca_entity.dart';
import '../viewmodels/finca_viewmodel.dart';
import 'registrar_finca_view.dart';

class FincasView extends StatefulWidget {
  const FincasView({super.key});

  @override
  State<FincasView> createState() => _FincasViewState();
}

class _FincasViewState extends State<FincasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().usuario?.uid;
      if (uid == null) return;
      context.read<FincaViewModel>().escucharFincas(uid);
      context.read<ParcelaViewModel>().escucharParcelasDeUsuario(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fincaVm = context.watch<FincaViewModel>();
    final parcelaVm = context.watch<ParcelaViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 14),
                  Text('Mis fincas',
                      style: AppTheme.displayFont(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: fincaVm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : fincaVm.fincas.isEmpty
                      ? _EstadoVacio(
                          onCrear: () => Navigator.of(context)
                              .pushNamed(AppRoutes.registrarFinca),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                          children: [
                            for (final finca in fincaVm.fincas)
                              _FincaCard(
                                finca: finca,
                                parcelas: parcelaVm.parcelas
                                    .where((p) => p.fincaId == finca.id)
                                    .toList(),
                              ),
                            const SizedBox(height: 4),
                            _BotonRegistrarParcela(
                              fincaId: fincaVm.fincaPrincipal?.id,
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

class _FincaCard extends StatelessWidget {
  final FincaEntity finca;
  final List<ParcelaEntity> parcelas;

  const _FincaCard({required this.finca, required this.parcelas});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(finca.nombre,
                    style: AppTheme.displayFont(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegistrarFincaView(fincaEditar: finca),
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.verdeMedio),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textoSecundario),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${finca.direccion} · ${finca.areaHectareas.toStringAsFixed(1)} ha · ${parcelas.length} parcelas',
                  style: AppTheme.bodyFont(
                      fontSize: 13, color: AppColors.textoSecundario),
                ),
              ),
            ],
          ),
          if (parcelas.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final p in parcelas)
              InkWell(
                onTap: () => _editarParcela(context, p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nombre,
                                style: AppTheme.bodyFont(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${p.areaHectareas.toStringAsFixed(1)} ha',
                                style: AppTheme.bodyFont(
                                    fontSize: 11,
                                    color: AppColors.textoSecundario)),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textoSecundario),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _editarParcela(BuildContext context, ParcelaEntity parcela) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditarParcelaSheet(parcela: parcela),
    );
  }
}

class _EditarParcelaSheet extends StatefulWidget {
  final ParcelaEntity parcela;
  const _EditarParcelaSheet({required this.parcela});

  @override
  State<_EditarParcelaSheet> createState() => _EditarParcelaSheetState();
}

class _EditarParcelaSheetState extends State<_EditarParcelaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.parcela.nombre);
    _areaController =
        TextEditingController(text: widget.parcela.areaHectareas.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ParcelaViewModel>();
    final ok = await vm.actualizarParcela(
      original: widget.parcela,
      nombre: _nombreController.text.trim(),
      areaHectareas: double.parse(_areaController.text.trim()),
    );
    if (ok && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Parcela actualizada')));
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ParcelaViewModel>();
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Editar parcela',
                style: AppTheme.displayFont(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Nombre de la parcela',
              controller: _nombreController,
              validator: (v) => Validators.requerido(v, campo: 'El nombre'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Área (hectáreas)',
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => Validators.numeroPositivo(v, campo: 'El área'),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Guardar cambios',
              loading: vm.isGuardando,
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonRegistrarParcela extends StatelessWidget {
  final String? fincaId;
  const _BotonRegistrarParcela({required this.fincaId});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: fincaId == null
          ? null
          : () => Navigator.of(context).pushNamed(
                AppRoutes.registrarParcela,
                arguments: fincaId,
              ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        side: const BorderSide(color: Color(0xFFB7C0B4), style: BorderStyle.solid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: AppColors.verdeMedio,
      ),
      icon: const Icon(Icons.add),
      label: Text('Registrar parcela',
          style: AppTheme.bodyFont(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onCrear;
  const _EstadoVacio({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.landscape_outlined,
                size: 48, color: AppColors.textoDeshabilitado),
            const SizedBox(height: 16),
            Text('Aún no registras ninguna finca',
                style: AppTheme.bodyFont(
                    fontSize: 14, color: AppColors.textoSecundario),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCrear,
              child: const Text('Registrar mi primera finca'),
            ),
          ],
        ),
      ),
    );
  }
}
