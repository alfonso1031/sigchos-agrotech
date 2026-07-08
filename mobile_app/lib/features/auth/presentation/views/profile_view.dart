import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/main_tab_bar.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
      bottomNavigationBar: const MainTabBar(current: TabItem.perfil),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  AppBackButton(onPressed: () {
                    final nav = Navigator.of(context);
                    if (nav.canPop()) {
                      nav.pop();
                    } else {
                      nav.pushReplacementNamed(AppRoutes.inicio);
                    }
                  }),
                  const SizedBox(width: 14),
                  Text('Perfil',
                      style: AppTheme.displayFont(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.editarPerfil),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.verdeMedio),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        (usuario.fotoUrl != null && usuario.fotoUrl!.isNotEmpty)
                            ? CircleAvatar(
                                radius: 38,
                                backgroundImage: NetworkImage(usuario.fotoUrl!),
                              )
                            : CircleAvatar(
                                radius: 38,
                                backgroundColor: AppColors.naranja,
                                child: Text(iniciales,
                                    style: AppTheme.displayFont(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                        const SizedBox(height: 12),
                        Text(usuario.nombre,
                            style: AppTheme.displayFont(
                                fontSize: 19, fontWeight: FontWeight.w600)),
                        Text(usuario.email,
                            style: AppTheme.bodyFont(
                                fontSize: 13, color: AppColors.textoSecundario)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (vm.necesitaCompletarPerfil)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.alertaFondo,
                        border: Border.all(color: AppColors.alertaBorde),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: AppColors.alertaTexto),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Completa tu cédula y teléfono para terminar tu perfil.',
                              style: AppTheme.bodyFont(
                                  fontSize: 13, color: AppColors.alertaTexto),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _Dato(
                      etiqueta: 'Cédula',
                      valor: usuario.cedula.isEmpty ? '—' : usuario.cedula),
                  _Dato(
                      etiqueta: 'Teléfono',
                      valor: usuario.telefono.isEmpty ? '—' : usuario.telefono),
                  _Dato(
                    etiqueta: 'Agricultor desde',
                    valor: DateFormat('dd/MM/yyyy').format(usuario.fechaRegistro),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await vm.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.login, (r) => false);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.severidadAlta,
                        side: const BorderSide(color: AppColors.severidadAlta),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
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

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Dato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: AppTheme.bodyFont(fontSize: 13, color: AppColors.textoSecundario)),
          Text(valor, style: AppTheme.bodyFont(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
