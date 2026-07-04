# Sigchos Agrotech

Detección de enfermedades en hojas de zapallo mediante inteligencia artificial.
Aplicación móvil (Flutter/Android) + panel web administrativo (Flutter Web),
construidas sobre un mismo proyecto de Firebase.

Un agricultor del cantón Sigchos (Cotopaxi, Ecuador) fotografía una hoja de
zapallo con la cámara del celular, un modelo de TensorFlow Lite la clasifica
en el propio dispositivo, y la app muestra el diagnóstico, el % de confianza,
recomendaciones agrícolas y la ubicación en un mapa de incidencia. El panel web
permite monitorear de forma agregada todos los diagnósticos, agricultores y el
rendimiento del modelo.

## Contenido

- [Estructura del repositorio](#estructura-del-repositorio)
- [Arquitectura](#arquitectura)
- [Funcionalidades](#funcionalidades)
- [Stack técnico](#stack-técnico)
- [Puesta en marcha](#puesta-en-marcha)
  - [Requisitos](#requisitos)
  - [1. Firebase](#1-firebase)
  - [2. Claves de API (mobile_app)](#2-claves-de-api-mobile_app)
  - [3. Correr la app móvil](#3-correr-la-app-móvil)
  - [4. Correr el panel web admin](#4-correr-el-panel-web-admin)
- [Modelo de IA (TensorFlow Lite)](#modelo-de-ia-tensorflow-lite)
- [Modelo de datos (Firestore)](#modelo-de-datos-firestore)
- [Reglas de seguridad](#reglas-de-seguridad)
- [Problemas conocidos](#problemas-conocidos)
- [Mejoras pendientes](#mejoras-pendientes)
- [Integrantes](#integrantes)

## Estructura del repositorio

```
PROYECTO FINAL/
├── firebase.json              # Config de Firebase Hosting + apunta a firebase/
├── firebase/
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   └── storage.rules
├── informe_avance.tex         # Informe académico (LaTeX, Overleaf)
├── mobile_app/                # App Android (Flutter)
│   ├── assets/
│   │   ├── images/logo.png
│   │   └── ml/model.tflite, labels.txt
│   ├── android/
│   │   ├── app/src/main/AndroidManifest.xml
│   │   ├── secrets.properties.example   # copiar como secrets.properties
│   │   └── app/build.gradle.kts
│   ├── lib/
│   │   ├── main.dart          # composición de dependencias + MultiProvider
│   │   ├── app.dart           # MaterialApp + rutas
│   │   ├── core/              # constants, errors, routes, theme, utils, widgets
│   │   ├── features/          # auth, fincas, parcelas, cultivos, diagnostico,
│   │   │                      # clima, historial, recomendaciones, mapa, inicio
│   │   └── services/          # TFLiteService, LocationService, StorageService,
│   │                          # NotificationService
│   └── tool/
│       ├── entrenar_modelo_colab.ipynb   # notebook de entrenamiento del modelo
│       └── seed_recomendaciones.dart     # poblar Firestore con recomendaciones
└── web_admin/                 # Panel administrativo (Flutter Web)
    └── lib/
        ├── core/               # models, services, theme, viewmodels, widgets
        └── features/           # auth, dashboard, diagnosticos, agricultores,
                                 # modelo_ia, shell
```

Cada *feature* de `mobile_app` sigue **Clean Architecture**:

```
features/<nombre>/
├── domain/           # entities, repositories (abstractas), usecases
├── data/             # models, datasources, repositories (implementación)
└── presentation/     # viewmodels (ChangeNotifier), views, widgets
```

## Arquitectura

- **Clean Architecture**: `domain` no depende de Flutter ni de Firebase;
  `presentation` depende de `domain`; `data` implementa las abstracciones de
  `domain`. Regla de dependencia unidireccional en las 9 *features* de la app
  móvil.
- **MVVM**: cada pantalla (`View`) observa un `ViewModel` (`ChangeNotifier`)
  mediante `context.watch<T>()`, y dispara acciones con `context.read<T>()`.
  El `ViewModel` llama a *casos de uso* (`UseCase`), nunca a Firebase
  directamente.
- **Provider**: gestor de estado. Todos los `ViewModel` se registran una sola
  vez en `main.dart` dentro de un único `MultiProvider`.
- **Composición de dependencias manual**: sin *service locator*; cada
  `DataSource` → `RepositoryImpl` → `UseCase` → `ViewModel` se construye a mano
  en `main.dart`, siguiendo la regla de dependencias de Clean Architecture.

## Funcionalidades

**App móvil**

- Registro/login con correo y contraseña o Google Sign-In.
- Gestión de fincas, parcelas y cultivos de zapallo (alta y edición).
- Captura de hoja con **cámara en vivo** embebida (no abre la app de cámara
  del sistema) o desde galería.
- Clasificación de la enfermedad con un modelo **TensorFlow Lite** on-device.
- Resultado con severidad, anillo de confianza, top-3 de probabilidades,
  definición de la enfermedad y mini-mapa satelital de la ubicación.
- Recomendaciones agrícolas por enfermedad.
- Historial de diagnósticos filtrable por clase.
- Mapa de zonas afectadas (satelital, filtros con/sin daño, navegación táctil
  a un foco, leyenda de severidad, botón "mi ubicación").
- Clima actual y pronóstico (OpenWeather) con alerta de riesgo fúngico según
  humedad y temperatura.
- Notificaciones locales (resultado de diagnóstico, recordatorio semanal).
- Edición de perfil con foto.
- Validaciones de cédula ecuatoriana (módulo 10), celular (prefijo 09) y
  campos obligatorios.
- Diálogos de aviso previos a solicitar permisos de cámara/GPS.

**Panel web administrativo**

- Acceso restringido a cuentas registradas en la colección `admins`
  (correo/contraseña o Google).
- **Resumen**: KPIs, gráfico de diagnósticos por día, distribución por clase,
  diagnósticos recientes, alertas de zona.
- **Diagnósticos**: tabla global filtrable por clase.
- **Agricultores**: fincas, parcelas y diagnósticos por usuario.
- **Modelo IA**: métricas del clasificador (accuracy, recall, latencia,
  tamaño, precisión por clase).

## Stack técnico

| Categoría | Tecnología |
|---|---|
| Framework | Flutter / Dart |
| Estado | Provider (`ChangeNotifier`) |
| Backend | Firebase (Authentication, Cloud Firestore, Storage) |
| IA on-device | TensorFlow Lite (`tflite_flutter`), MobileNetV2 (transfer learning) |
| Mapas | `google_maps_flutter` |
| Clima | OpenWeather API (REST) |
| Hardware | `camera`, `geolocator`, `image_picker`, `permission_handler` |
| Notificaciones | `flutter_local_notifications` |
| Web admin | Flutter Web + `fl_chart` |

## Puesta en marcha

### Requisitos

- Flutter SDK 3.x, Dart 3.x
- Cuenta de Firebase con Firestore, Authentication y Storage (plan Blaze para
  Storage)
- Node.js (para `firebase-tools`) y `flutterfire_cli`
- Android SDK / dispositivo o emulador Android

### 1. Firebase

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli

cd mobile_app
flutterfire configure --project=<tu-id-de-proyecto> --platforms=android

cd ../web_admin
flutterfire configure --project=<tu-id-de-proyecto> --platforms=web
```

Habilita en la consola de Firebase:

- **Authentication** → Sign-in method → Email/Password y Google.
- **Firestore Database** (modo nativo).
- **Storage** (requiere plan Blaze).

Despliega reglas e índices desde la raíz del repo:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Crea manualmente un documento en la colección `admins` con **ID = tu UID de
Firebase Auth** para poder entrar al panel web.

### 2. Claves de API (mobile_app)

Dos archivos con claves reales están excluidos del repositorio
(`.gitignore`). Cópialos desde su plantilla `.example` y completa tus claves:

```bash
cd mobile_app
cp lib/core/constants/api_keys.dart.example lib/core/constants/api_keys.dart
cp android/secrets.properties.example android/secrets.properties
```

- `lib/core/constants/api_keys.dart` → tu API key de
  [OpenWeather](https://openweathermap.org/api).
- `android/secrets.properties` → tu API key de **Google Maps SDK for
  Android**, leída por Gradle e inyectada en el `AndroidManifest.xml` vía
  `manifestPlaceholders` (nunca se hardcodea en el manifest ni se sube al
  repo).

### 3. Correr la app móvil

```bash
cd mobile_app
flutter pub get
flutter run
```

### 4. Correr el panel web admin

```bash
cd web_admin
flutter pub get
flutter run -d chrome
```

Despliegue a Firebase Hosting:

```bash
cd web_admin && flutter build web
cd ..
firebase deploy --only hosting
```

## Modelo de IA (TensorFlow Lite)

El clasificador se entrenó por transferencia de aprendizaje sobre
**MobileNetV2** en Google Colab (notebook:
`mobile_app/tool/entrenar_modelo_colab.ipynb`), usando el dataset público
[Pumpkin Leaf Diseases Dataset From Bangladesh](https://www.kaggle.com/datasets/tahmidmir/pumpkin-leaf-diseases-dataset-from-bangladesh)
(Kaggle, 2000 imágenes, 5 clases).

Clases cubiertas por el modelo: `hoja_sana`, `mancha_foliar`, `mildiu`,
`oidio`, `amarillamiento`. La clase `dano_plaga` se quitó del catálogo, los
colores y las recomendaciones de la app y del panel web — no existe dataset
público adecuado para entrenarla; se retomará cuando se consiga uno propio.

Métricas reales sobre el set de validación (400 imágenes,
`classification_report` — ver notebook celda 20): **83% accuracy**, **83%
recall macro**. Por clase, precisión más floja en `mancha_foliar` (66%,
confundida con mildiu/oídio) y recall más flojo en `oidio` (72%). Detalle en
el panel web, sección "Modelo IA".

`TFLiteService` (`mobile_app/lib/services/tflite_service.dart`) carga
`assets/ml/model.tflite`; si el asset no existe o falla la carga, cae a un
**modo simulado** para que el flujo de la app siga siendo demostrable durante
el desarrollo.

Para reentrenar: abre el notebook en Colab, sigue las celdas (descarga el
dataset, mapea carpetas, entrena, convierte a `.tflite`) y reemplaza
`assets/ml/model.tflite` + `assets/ml/labels.txt`.

## Modelo de datos (Firestore)

| Colección | Campos principales |
|---|---|
| `usuarios` | nombre, cedula, telefono, email, fotoUrl, rol, fechaRegistro |
| `fincas` | usuarioId, nombre, ubicacion (GeoPoint), direccion, areaHectareas |
| `parcelas` | fincaId, usuarioId, nombre, areaHectareas, ubicacion (GeoPoint) |
| `cultivos` | parcelaId, usuarioId, variedad, fechaSiembra, plantasEstimadas, etapa |
| `diagnosticos_hojas` | usuarioId, cultivoId, imagenUrl, enfermedad, confianza, top3[], ubicacion, climaSnapshot, fecha |
| `recomendaciones` | enfermedad, orden, titulo, descripcion |
| `admins` | existencia del documento (uid) = permiso de administrador |
| `clima`, `alertas` | reservadas para historial climático y notificaciones (no pobladas activamente aún) |

## Reglas de seguridad

Definidas en `firebase/firestore.rules` y `firebase/storage.rules`: exigen
autenticación y verifican propiedad del documento
(`resource.data.usuarioId == request.auth.uid`) o pertenencia a `admins` para
lectura ampliada. `recomendaciones` es de lectura pública para usuarios
autenticados y escritura restringida a administradores.

## Problemas conocidos

- **Firebase Storage** exige plan Blaze incluso dentro de la capa gratuita;
  la subida de imágenes es tolerante a fallo (el diagnóstico se guarda igual
  sin imagen en la nube si Storage no está disponible).
- El **emulador de Android Studio** resultó inestable en el equipo de
  desarrollo; las pruebas se hicieron en dispositivo físico vía USB
  debugging.
- El modelo de IA no cubre la clase `dano_plaga`; se quitó de la app (ver arriba).

## Mejoras pendientes

- Conseguir dataset propio de `dano_plaga` y reincorporar la clase.
- Sumar más datos de `mancha_foliar` (precisión más baja, 66%, confundida con mildiu/oídio).
- Publicar en Play Store (cuenta en proceso de verificación).
- CRUD de recomendaciones y alertas desde el panel web.
- Poblar activamente las colecciones `clima`/`alertas` para notificaciones
  push reales basadas en servidor.
- Pruebas automatizadas (unitarias e instrumentadas).
- Modo sin conexión con caché local.

## Integrantes

- Alfonso Arroyo
- Pedro Frías
- Ariel Llumiquinga
- Germán Cáceres
