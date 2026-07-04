import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Mapa de Google real con el punto GPS capturado (usa Geolocator para la
/// posición + Google Maps para la vista previa), tal como aparece en
/// "Registrar parcela" del prototipo.
class GpsPreviewCard extends StatelessWidget {
  final double? lat;
  final double? lng;
  final bool cargando;
  final VoidCallback onCapturar;

  const GpsPreviewCard({
    super.key,
    required this.lat,
    required this.lng,
    required this.onCapturar,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final tieneUbicacion = lat != null && lng != null;
    return InkWell(
      onTap: onCapturar,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: cargando
            ? Container(
                color: AppColors.inputFill,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2.4),
              )
            : tieneUbicacion
                ? Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: LatLng(lat!, lng!), zoom: 17),
                        markers: {
                          Marker(
                            markerId: const MarkerId('ubicacion'),
                            position: LatLng(lat!, lng!),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        liteModeEnabled: true,
                        onMapCreated: (_) {},
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}',
                            style: AppTheme.monoFont(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.refresh, size: 16, color: AppColors.verdeMedio),
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFDCE6DA), Color(0xFFE8EFE2)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location,
                            color: AppColors.textoSecundario, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          'Toca para capturar ubicación GPS',
                          style: AppTheme.monoFont(
                              fontSize: 11, color: const Color(0xFF3C5A44)),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
