import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AdminSection { resumen, diagnosticos, agricultores, modeloIa }

class AdminSidebar extends StatelessWidget {
  final AdminSection current;
  final int totalDiagnosticos;
  final String nombreAdmin;
  final void Function(AdminSection) onNavegar;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.current,
    required this.totalDiagnosticos,
    required this.nombreAdmin,
    required this.onNavegar,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.verdeSidebar,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 42, height: 42),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sigchos',
                      style: AppTheme.display(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('AGROTECH · ADMIN',
                      style: AppTheme.body(fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('MONITOREO',
                style: AppTheme.mono(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))
                    .copyWith(letterSpacing: 1.4)),
          ),
          const SizedBox(height: 10),
          _item(Icons.grid_view_outlined, 'Resumen', AdminSection.resumen),
          _item(Icons.eco_outlined, 'Diagnósticos', AdminSection.diagnosticos,
              badge: totalDiagnosticos > 0 ? _formatoK(totalDiagnosticos) : null),
          _item(Icons.people_outline, 'Agricultores', AdminSection.agricultores),
          _item(Icons.hub_outlined, 'Modelo IA', AdminSection.modeloIa),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF3DDC84), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('Servicios activos',
                        style: AppTheme.body(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Firebase · Firestore\nTFLite · OpenWeather',
                    style: AppTheme.body(fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.naranja,
                child: Text(
                  nombreAdmin.isNotEmpty ? nombreAdmin[0].toUpperCase() : 'A',
                  style: AppTheme.display(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.verdeSidebar),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(nombreAdmin,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              IconButton(
                onPressed: onLogout,
                icon: Icon(Icons.logout, size: 18, color: Colors.white.withValues(alpha: 0.7)),
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatoK(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  Widget _item(IconData icon, String label, AdminSection section, {String? badge}) {
    final activo = section == current;
    return InkWell(
      onTap: () => onNavegar(section),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: activo ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: activo ? Colors.white : Colors.white.withValues(alpha: 0.62)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTheme.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: activo ? Colors.white : Colors.white.withValues(alpha: 0.62),
                  )),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(badge,
                    style: AppTheme.mono(fontSize: 11, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
