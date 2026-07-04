import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_gradient_field.dart';

/// Pantalla de registro — no estaba prototipada explícitamente en el diseño
/// (solo el link "Regístrate" en Login), se replica el mismo lenguaje visual
/// del gradiente verde y campos translúcidos.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final ok = await vm.register(
      nombre: _nombreController.text.trim(),
      cedula: _cedulaController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.inicio);
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteLogin),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crear cuenta',
                    style: AppTheme.displayFont(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Regístrate como agricultor para empezar a diagnosticar tus cultivos.',
                    style: AppTheme.bodyFont(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthGradientField(
                    label: 'Nombre completo',
                    controller: _nombreController,
                    validator: (v) =>
                        Validators.requerido(v, campo: 'El nombre'),
                  ),
                  const SizedBox(height: 14),
                  AuthGradientField(
                    label: 'Cédula',
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    validator: Validators.cedulaEcuatoriana,
                  ),
                  const SizedBox(height: 14),
                  AuthGradientField(
                    label: 'Teléfono',
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.telefono,
                  ),
                  const SizedBox(height: 14),
                  AuthGradientField(
                    label: 'Correo',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 14),
                  AuthGradientField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 14),
                  AuthGradientField(
                    label: 'Confirmar contraseña',
                    controller: _confirmarController,
                    obscureText: true,
                    validator: (v) => Validators.confirmarPassword(
                      v,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.verdeOscuro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.verdeOscuro,
                              ),
                            )
                          : Text(
                              'Crear cuenta',
                              style: AppTheme.displayFont(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.verdeOscuro,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
