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
- [x] Dibujar fincas como polígono (contorno real), no solo un pin.
  - Vértices del borde guardados en `FincaEntity.limite` (`List<GeoPunto>`) y en Firestore como `List<GeoPoint>`.
  - `registrar_finca_view`: mapa interactivo, tocar para marcar esquinas, botones Deshacer/Limpiar y "mi ubicación".
  - Área calculada automáticamente del polígono (fórmula esférica en `GeoUtils.areaHectareas`); centro = centroide.
  - `mapa_view` pinta el contorno con `polygons:`; el pin queda como respaldo/etiqueta.
  - Compatibilidad: fincas antiguas sin `limite` siguen mostrando solo el pin y área manual.
  - Archivos nuevos: `core/models/geo_punto.dart`, `core/utils/geo_utils.dart`.

## Mapa / Fincas (web admin)
- [ ] Agregar trazado del polígono de la finca sobre el mapa en web_admin (actualmente solo mobile_app lo dibuja).

## Clima / Modelo IA
- [ ] Revisar que recomendaciones se den según clima de ubicación (finca).
- [ ] Entrenar modelo también según clima de ubicación.
- [ ] Entrenar modelo con más enfermedades comunes de hojas.
