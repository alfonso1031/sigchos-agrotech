import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/cultivo_viewmodel.dart';

const _variedades = ['Macre', 'Loche', 'Italiano'];

/// Paso 2 de 2 del alta de cultivo (llega desde RegistrarParcelaView).
class RegistrarCultivoView extends StatefulWidget {
  final String parcelaId;
  const RegistrarCultivoView({super.key, required this.parcelaId});

  @override
  State<RegistrarCultivoView> createState() => _RegistrarCultivoViewState();
}

class _RegistrarCultivoViewState extends State<RegistrarCultivoView> {
  final _formKey = GlobalKey<FormState>();
  final _plantasController = TextEditingController();
  String _variedad = _variedades.first;
  DateTime _fechaSiembra = DateTime.now();

  @override
  void dispose() {
    _plantasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSiembra,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaSiembra = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = context.read<AuthViewModel>().usuario!.uid;
    final vm = context.read<CultivoViewModel>();
    final ok = await vm.crearCultivo(
      parcelaId: widget.parcelaId,
      usuarioId: uid,
      variedad: _variedad,
      fechaSiembra: _fechaSiembra,
      plantasEstimadas: int.parse(_plantasController.text.trim()),
    );
    if (ok && mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.inicio, (route) => false);
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CultivoViewModel>();
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
                        Text('Registrar cultivo',
                            style: AppTheme.displayFont(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Paso 2 de 2',
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
                    Text('VARIEDAD DE ZAPALLO',
                        style: AppTheme.monoFont(fontSize: 11)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final v in _variedades)
                          ChoiceChip(
                            label: Text(v),
                            selected: _variedad == v,
                            onSelected: (_) => setState(() => _variedad = v),
                            selectedColor: AppColors.verdeMedio,
                            labelStyle: TextStyle(
                              color: _variedad == v
                                  ? Colors.white
                                  : AppColors.textoSecundario,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: AppColors.card,
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('FECHA DE SIEMBRA',
                        style: AppTheme.monoFont(fontSize: 11)
                            .copyWith(letterSpacing: 1.1)),
                    const SizedBox(height: 7),
                    InkWell(
                      onTap: _seleccionarFecha,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd / MM / yyyy').format(_fechaSiembra),
                              style: AppTheme.bodyFont(fontSize: 15),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppColors.textoSecundario),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Plantas estimadas',
                      controller: _plantasController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.numeroPositivo(v, campo: 'La cantidad'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppPrimaryButton(
                  label: 'Guardar cultivo',
                  loading: vm.isGuardando,
                  backgroundColor: AppColors.verdeOscuro,
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
