import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'admin_auth_viewmodel.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AdminAuthViewModel>();
    final ok = await vm.login(_emailController.text.trim(), _passwordController.text);
    if (!ok && mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  Future<void> _ingresarConGoogle() async {
    final vm = context.read<AdminAuthViewModel>();
    final ok = await vm.loginConGoogle();
    if (!ok && mounted && vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAuthViewModel>();
    return Scaffold(
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 46, height: 46),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sigchos', style: AppTheme.display(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('AGROTECH · ADMIN',
                            style: AppTheme.mono(fontSize: 11, color: AppColors.textoSecundario)
                                .copyWith(letterSpacing: 1)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Ingresar al panel', style: AppTheme.display(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Solo cuentas administradoras autorizadas',
                    style: AppTheme.body(fontSize: 13, color: AppColors.textoSecundario)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu correo' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                  onFieldSubmitted: (_) => _ingresar(),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _ingresar,
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Ingresar'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('o',
                          style: AppTheme.body(
                              fontSize: 13, color: AppColors.textoSecundario)),
                    ),
                    Expanded(child: Divider(color: AppColors.cardBorder)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: vm.isLoading ? null : _ingresarConGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)),
                      foregroundColor: AppColors.textoPrimario,
                    ),
                    icon: const _GoogleG(size: 20),
                    label: Text('Continuar con Google',
                        style: AppTheme.body(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  final double size;
  const _GoogleG({required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: Text('G',
          style: TextStyle(
              fontSize: size, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}
