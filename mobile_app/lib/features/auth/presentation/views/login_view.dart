import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_gradient_field.dart';
import '../widgets/google_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final ok = await vm.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.inicio);
    } else if (mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    }
  }

  Future<void> _ingresarConGoogle() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.loginConGoogle();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          const AppLogo(size: 76),
                          const SizedBox(height: 24),
                          Text(
                            'Sigchos\nAgrotech',
                            style: AppTheme.displayFont(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ).copyWith(height: 1.05),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 280,
                            child: Text(
                              'Detección de enfermedades foliares en hojas de zapallo con inteligencia artificial.',
                              style: AppTheme.bodyFont(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: vm.isLoading ? null : _ingresar,
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
                                      'Ingresar',
                                      style: AppTheme.displayFont(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.verdeOscuro,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _divisorO(),
                          const SizedBox(height: 18),
                          GoogleButton(
                            onPressed: vm.isLoading ? null : _ingresarConGoogle,
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            child: Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.registro),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTheme.bodyFont(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.72),
                                    ),
                                    children: [
                                      const TextSpan(text: '¿No tienes cuenta? '),
                                      TextSpan(
                                        text: 'Regístrate',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _divisorO() {
    final linea = Expanded(
      child: Divider(color: Colors.white.withValues(alpha: 0.25), thickness: 1),
    );
    return Row(
      children: [
        linea,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('o',
              style: AppTheme.bodyFont(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
        ),
        linea,
      ],
    );
  }
}
