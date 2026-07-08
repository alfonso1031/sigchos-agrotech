# Pendientes

## UI / Login
- [x] Agregar ícono de "ojito" (mostrar/ocultar contraseña) en el campo de contraseña del login.
  - Archivo: `mobile_app/lib/features/auth/presentation/views/login_view.dart`
  - Widget de campo: `mobile_app/lib/features/auth/presentation/widgets/auth_gradient_field.dart`
- [x] Agregar ícono de "ojito" (mostrar/ocultar contraseña) en el campo contraseña de Registro.
  - Archivo: `mobile_app/lib/features/auth/presentation/views/register_view.dart`

## Validaciones / Registro
- [x] Validar cédula: solo permitir 10 caracteres (numéricos).
  - Archivo: `mobile_app/lib/features/auth/presentation/views/register_view.dart`
- [x] Validar teléfono: solo permitir 10 caracteres (numéricos).
  - Archivo: `mobile_app/lib/features/auth/presentation/views/register_view.dart`

## Mapa / Fincas
- [ ] Dibujar fincas como polígono (contorno real), no solo un pin.
  - Guardar `List<LatLng>` (vértices del borde) en `FincaEntity` + Firestore.
  - UI de dibujo en `registrar_finca_view`: tocar mapa para marcar esquinas.
  - Pintar con `polygons:` de `GoogleMap` en vez de `Marker`.
  - Calcular `areaHectareas` desde el polígono en vez de pedirla a mano.
  - Beneficio: ver extensión real, saber en qué finca cae cada diagnóstico, parcelas como sub-polígonos.
  - Archivos: `mobile_app/lib/features/fincas/domain/entities/finca_entity.dart`, `.../presentation/views/registrar_finca_view.dart`, `mobile_app/lib/features/mapa/presentation/views/mapa_view.dart`
