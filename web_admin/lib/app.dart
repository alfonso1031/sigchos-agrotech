import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/admin_auth_viewmodel.dart';
import 'features/auth/admin_login_view.dart';
import 'features/shell/admin_shell.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sigchos Agrotech · Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<AdminAuthViewModel>(
        builder: (context, authVm, _) {
          return authVm.autenticado ? const AdminShell() : const AdminLoginView();
        },
      ),
    );
  }
}
