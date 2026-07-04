import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _cedulaController;
  late final TextEditingController _telefonoController;
  File? _nuevaFoto;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthViewModel>().usuario;
    _nombreController = TextEditingController(text: u?.nombre ?? '');
    _cedulaController = TextEditingController(text: u?.cedula ?? '');
    _telefonoController = TextEditingController(text: u?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (archivo != null) {
      setState(() => _nuevaFoto = File(archivo.path));
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final ok = await vm.actualizarPerfil(
      nombre: _nombreController.text.trim(),
      cedula: _cedulaController.text.trim(),
      telefono: _telefonoController.text.trim(),
      nuevaFotoPath: _nuevaFoto?.path,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      Navigator.of(context).pop();
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final usuario = vm.usuario!;
    final iniciales = usuario.nombre
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

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
                    Text('Editar perfil',
                        style: AppTheme.displayFont(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          _avatar(usuario.fotoUrl, iniciales),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _elegirFoto,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.verdeMedio,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _elegirFoto,
                        child: Text(
                          _nuevaFoto == null ? 'Cambiar foto' : 'Foto seleccionada ✓',
                          style: AppTheme.bodyFont(
                              fontSize: 13, color: AppColors.verdeMedio),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Nombre completo',
                      controller: _nombreController,
                      validator: (v) => Validators.requerido(v, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Cédula',
                      controller: _cedulaController,
                      keyboardType: TextInputType.number,
                      validator: Validators.cedulaEcuatoriana,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Teléfono',
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.telefono,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mail_outline,
                              size: 18, color: AppColors.textoSecundario),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(usuario.email,
                                style: AppTheme.bodyFont(
                                    fontSize: 13,
                                    color: AppColors.textoSecundario)),
                          ),
                          Text('No editable',
                              style: AppTheme.bodyFont(
                                  fontSize: 11,
                                  color: AppColors.textoDeshabilitado)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: AppPrimaryButton(
                  label: 'Guardar cambios',
                  loading: vm.isLoading,
                  onPressed: _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? fotoUrl, String iniciales) {
    const size = 92.0;
    if (_nuevaFoto != null) {
      return CircleAvatar(radius: size / 2, backgroundImage: FileImage(_nuevaFoto!));
    }
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      return CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(fotoUrl));
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.naranja,
      child: Text(iniciales,
          style: AppTheme.displayFont(
              fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}
