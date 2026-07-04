import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

enum TabItem { inicio, historial, mapa, clima, perfil }

/// Tab bar flotante con FAB central de cámara — sección `showTab` del
/// prototipo. Cambia de pantalla con pushReplacement para no acumular pila.
class MainTabBar extends StatelessWidget {
  final TabItem current;
  const MainTabBar({super.key, required this.current});

  void _ir(BuildContext context, TabItem tab, String ruta) {
    if (tab == current) return;
    Navigator.of(context).pushReplacementNamed(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, Icons.home_outlined, 'Inicio', TabItem.inicio, AppRoutes.inicio),
          _item(context, Icons.history, 'Historial', TabItem.historial, AppRoutes.historial),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.captura),
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.naranja,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.naranja.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
            ),
          ),
          _item(context, Icons.map_outlined, 'Mapa', TabItem.mapa, AppRoutes.mapa),
          _item(context, Icons.person_outline, 'Perfil', TabItem.perfil, AppRoutes.perfil),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    TabItem tab,
    String ruta,
  ) {
    final activo = tab == current;
    final color = activo ? AppColors.verdeOscuro : AppColors.textoDeshabilitado;
    return InkWell(
      onTap: () => _ir(context, tab, ruta),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
