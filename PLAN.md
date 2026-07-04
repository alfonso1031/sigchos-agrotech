# Sigchos Agrotech — Plan Maestro del Proyecto Final

**Proyecto:** Detección de Enfermedades en Hojas de Zapallo
**Fecha:** Julio 2026
**Cuenta Firebase:** arroyoalfonso1031@gmail.com

---

## 1. Visión general

Aplicación móvil inteligente que detecta enfermedades en hojas de zapallo mediante fotos tomadas con la cámara del celular. Un modelo de IA (TensorFlow Lite) analiza la imagen en el dispositivo, muestra el diagnóstico con porcentaje de confianza y genera recomendaciones agrícolas. Incluye clima local (OpenWeather + GPS), historial de diagnósticos y gestión de fincas/parcelas/cultivos. Se complementa con una **aplicación web administrativa** para monitoreo del sistema.

**Problema:** los agricultores identifican enfermedades foliares de forma visual, generando diagnósticos tardíos que afectan el crecimiento de la planta.

---

## 2. Estructura del repositorio

```
PROYECTO FINAL/
├── PLAN.md                  ← este documento
├── firebase.json            ← config Firebase (rules + hosting de web_admin)
├── firebase/                ← firestore.rules, firestore.indexes.json, storage.rules
├── sigchos-agrotech/        ← Bundle de diseño Claude Design (prototipos HTML — solo referencia)
├── mobile_app/              ← Aplicación móvil Flutter (Android) — ✅ código completo, falta Firebase real
│   └── tool/seed_recomendaciones.dart  ← puebla Firestore con las 24 recomendaciones del prototipo
└── web_admin/               ← Aplicación web administrativa (Flutter Web) — ✅ código completo, falta Firebase real
```

**Estado de implementación (código):** `flutter analyze` sin issues en ambos proyectos. Pendiente real: conectar Firebase (`flutterfire configure`, bloqueado en `firebase login` — requiere navegador interactivo), entrenar el modelo TFLite real (hoy corre en modo simulado, ver sección 8), y las API keys de OpenWeather/Google Maps.

Ambas apps comparten el mismo proyecto de Firebase (Auth + Firestore + Storage).

**Decisión técnica — web admin en Flutter Web:** mismo lenguaje (Dart), reutiliza modelos y conocimiento de Firebase, un solo stack que dominar antes del examen. Alternativa descartada: React (segundo stack = más riesgo de tiempo).

---

## 3. Mapeo contra la rúbrica (4 puntos)

| Requisito | Cómo se cumple |
|---|---|
| Instalación en celular/emulador | APK release instalable + emulador Android |
| Login funcional | Firebase Authentication (email/contraseña) |
| Mínimo 4 pantallas | 12+ pantallas (ver sección 5) |
| Uso de Provider | `ChangeNotifierProvider` + `MultiProvider`, un ViewModel por pantalla |
| Firebase / base de datos | Firestore (9 colecciones) + Firebase Storage |
| Consumo de API REST | OpenWeather API (clima actual + pronóstico) vía `http` |
| Hardware móvil | Cámara (captura de hoja) + GPS (geolocalización de finca/diagnóstico) |
| Navegación entre pantallas | Rutas nombradas con `onGenerateRoute` (Navigator 2.0 opcional) |
| Validaciones | `Form` + `TextFormField` con validators en todos los formularios |
| Clean Architecture | Capas `domain / data / presentation` estrictas |
| Patrón MVVM | View (widgets) ↔ ViewModel (ChangeNotifier) ↔ UseCases |
| Separación de responsabilidades | entities, models, datasources, repositories, usecases, viewmodels, views, widgets |
| Web administrativa | Proyecto separado `web_admin/` (no es rol dentro de la app) |
| Play Store | Sección 12 (cuenta en verificación — plan B: APK firmado) |

---

## 4. Arquitectura (Clean Architecture + MVVM + Provider)

### Estructura de carpetas `mobile_app/lib/`

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, tema, MultiProvider
├── core/
│   ├── constants/                    # colores, strings, rutas de assets
│   ├── errors/                       # Failure, excepciones
│   ├── network/                      # cliente http base
│   ├── routes/                       # app_routes.dart (rutas nombradas)
│   ├── theme/                        # tema según diseño .dc.html
│   └── utils/                        # validators.dart, formatters
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/             # usuario_entity.dart
│   │   │   ├── repositories/         # auth_repository.dart (abstracto)
│   │   │   └── usecases/             # login_usecase, register_usecase, logout_usecase
│   │   ├── data/
│   │   │   ├── models/               # usuario_model.dart (extends entity, fromJson/toJson)
│   │   │   ├── datasources/          # auth_firebase_datasource.dart
│   │   │   └── repositories/         # auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── viewmodels/           # auth_viewmodel.dart (ChangeNotifier)
│   │       ├── views/                # login_view.dart, register_view.dart
│   │       └── widgets/              # campos, botones propios del feature
│   ├── fincas/          (misma estructura: domain/data/presentation)
│   ├── parcelas/
│   ├── cultivos/
│   ├── diagnostico/     (cámara + TFLite + resultado)
│   ├── clima/           (OpenWeather + GPS)
│   ├── historial/
│   ├── recomendaciones/
│   └── mapa/            (Google Maps con fincas y diagnósticos)
└── services/
    ├── tflite_service.dart           # carga modelo, clasifica imagen
    ├── location_service.dart         # geolocator
    ├── notification_service.dart     # notificaciones locales
    └── storage_service.dart          # subida de imágenes
```

### Flujo MVVM

```
View (StatelessWidget + Consumer)
   → ViewModel (ChangeNotifier: estado, loading, error)
      → UseCase (lógica de negocio, 1 clase = 1 acción)
         → Repository (abstracción en domain)
            → RepositoryImpl (data)
               → DataSource (Firebase / API REST / TFLite)
```

**Regla de dependencias:** presentation → domain ← data. `domain` no importa nada de Flutter ni Firebase.

### Providers registrados en `main.dart`

`AuthViewModel`, `FincaViewModel`, `ParcelaViewModel`, `CultivoViewModel`, `DiagnosticoViewModel`, `ClimaViewModel`, `HistorialViewModel`, `RecomendacionViewModel`, `MapaViewModel`.

---

## 5. Pantallas de la app móvil (mínimo 4 → se implementan 13)

| # | Pantalla | Feature | Detalle |
|---|---|---|---|
| 1 | Splash | core | Verifica sesión activa, redirige a login/home |
| 2 | Login | auth | Email + contraseña, validaciones, error de credenciales |
| 3 | Registro de agricultor | auth | Nombre, cédula, teléfono, email, contraseña (confirmación) |
| 4 | Home / Dashboard | core | Accesos rápidos, clima resumido, últimos diagnósticos |
| 5 | Fincas (lista + formulario) | fincas | CRUD, ubicación GPS con botón "usar mi ubicación" |
| 6 | Parcelas (lista + formulario) | parcelas | CRUD anidado bajo finca, área en m² |
| 7 | Cultivos de zapallo | cultivos | CRUD bajo parcela, variedad, fecha de siembra, etapa |
| 8 | Captura de hoja | diagnostico | Cámara o galería, previsualización, guía de encuadre |
| 9 | Resultado del diagnóstico | diagnostico | Enfermedad detectada, % de confianza, top-3 clases, imagen |
| 10 | Historial de diagnósticos | historial | Lista filtrable por cultivo/enfermedad/fecha |
| 11 | Detalle de diagnóstico | historial | Imagen, resultado, clima del momento, recomendación asociada |
| 12 | Clima | clima | Clima actual + pronóstico 5 días según GPS, alerta de riesgo fúngico |
| 13 | Mapa de fincas | mapa | Google Maps con marcadores de fincas y diagnósticos (color según enfermedad) |
| + | Recomendaciones | recomendaciones | Consejos por enfermedad detectada (desde Firestore) |
| + | Perfil | auth | Datos del agricultor, cerrar sesión |

**Pantallas extra propuestas (valor agregado):**
- **Alerta de riesgo climático:** si humedad > 80% y temperatura 15–25 °C → notificación "condiciones favorables para mildiu".
- **Estadísticas del agricultor:** gráfico de diagnósticos por mes y por enfermedad (`fl_chart`).

---

## 6. Modelo de datos — Firestore

```
usuarios/{uid}
  nombre, cedula, telefono, email, rol ("agricultor"), fotoUrl?, fechaRegistro

fincas/{fincaId}
  usuarioId, nombre, ubicacion (GeoPoint), direccion, areaHectareas, fechaCreacion

parcelas/{parcelaId}
  fincaId, usuarioId, nombre, areaM2, tipoSuelo, fechaCreacion

cultivos/{cultivoId}
  parcelaId, usuarioId, variedad, fechaSiembra, etapa ("germinacion"|"crecimiento"|"floracion"|"cosecha"), estado ("activo"|"finalizado")

diagnosticos_hojas/{diagId}
  usuarioId, cultivoId, imagenUrl, enfermedad, confianza (0–1),
  top3 [{clase, prob}], ubicacion (GeoPoint), climaSnapshot {temp, humedad, descripcion},
  fecha, recomendacionId

imagenes_hojas/{imgId}
  diagnosticoId, usuarioId, url, storagePath, fecha

clima/{registroId}
  usuarioId, ubicacion (GeoPoint), temp, humedad, presion, descripcion, icono, fecha

alertas/{alertaId}
  usuarioId, tipo ("clima"|"enfermedad"), titulo, mensaje, leida, fecha

recomendaciones/{recoId}
  enfermedad, titulo, descripcion, acciones [string], productosSugeridos [string], severidad
```

**Colección extra:** `admins/{uid}` — emails autorizados para la web administrativa.

### Reglas de seguridad (base)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usuarios/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /recomendaciones/{doc} {
      allow read: if request.auth != null;
      allow write: if exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    match /{coleccion}/{doc} {
      allow read, write: if request.auth != null &&
        (resource == null || resource.data.usuarioId == request.auth.uid ||
         exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
    }
  }
}
```

---

## 7. Configuración de Firebase — ✅ CONECTADO (cuenta arroyoalfonso1031@gmail.com)

### 7.1 Proyecto

**ID real del proyecto: `agrotech-19ec5`** (nombre visible "AgroTech", plan Spark).

### 7.2 Herramientas CLI — ✅ instaladas

`firebase-tools` (npm global) y `flutterfire_cli` (dart pub global) ya instalados y con sesión iniciada (`firebase login` hecho).

### 7.3 Apps conectadas — ✅ hecho

```powershell
flutterfire configure --project=agrotech-19ec5 --platforms=android --android-package-name=com.sigchos.mobile_app --yes   # mobile_app
flutterfire configure --project=agrotech-19ec5 --platforms=web --yes                                                     # web_admin
```

`lib/firebase_options.dart` generado con credenciales reales en ambos proyectos. `.firebaserc` en la raíz apunta a `agrotech-19ec5`.

### 7.4 Firestore — ✅ creado y reglas desplegadas

`firebase deploy --only firestore:rules,firestore:indexes` creó la base de datos Firestore (default) y subió `firebase/firestore.rules` + `firebase/firestore.indexes.json`.

### 7.5 Pendiente manual (consola, no automatizable)

- **Authentication → Sign-in method → habilitar Email/Password** (1 clic).
- **Storage:** requiere upgrade a plan **Blaze** (tarjeta, capa gratis 5GB) en console.firebase.google.com/project/agrotech-19ec5/storage → "Get started". Sin esto, `firebase deploy --only storage` falla y subir imágenes de diagnóstico no funciona.
- Poblar `recomendaciones`: `dart run tool/seed_recomendaciones.dart` (dentro de `mobile_app/`).
- Crear doc `admins/{uid}` manualmente en consola para el primer administrador del panel web (el uid se obtiene después de que esa persona se registre como agricultor, o creando el usuario directo en Authentication).

### 7.4 Activar Authentication

1. Consola → **Build → Authentication → Get started**.
2. Pestaña **Sign-in method** → habilitar **Email/Password** → guardar.

### 7.5 Activar Firestore

1. Consola → **Build → Firestore Database → Create database**.
2. Ubicación: `southamerica-east1` (São Paulo) o `us-central1`.
3. Empezar en **modo de prueba** (desarrollo) → antes de la entrega, pegar las reglas de la sección 6.

### 7.6 Activar Storage

> ⚠️ **Importante:** desde octubre 2024 Firebase Storage en proyectos nuevos exige el plan **Blaze** (requiere tarjeta, pero tiene capa gratuita de 5 GB — no genera cobro en un proyecto académico).

1. Consola → **Build → Storage → Get started** → si pide upgrade, activar Blaze con tarjeta.
2. **Plan B sin tarjeta:** usar **Cloudinary** (gratuito, API REST — además suma otro consumo de API REST a la rúbrica). Subida vía `POST https://api.cloudinary.com/v1_1/<cloud>/image/upload` con upload preset unsigned, guardar la URL resultante en Firestore.

### 7.7 Dependencias Android

En `android/app/build.gradle`: `minSdkVersion 24`, `compileSdkVersion 35`. El plugin de Google Services lo configura `flutterfire configure`.

### 7.8 Poblar datos iniciales

Crear manualmente en la consola (o con script) los 6 documentos de `recomendaciones` (uno por enfermedad) y el documento `admins/{uid-del-admin}`.

---

## 8. Modelo TensorFlow Lite (detección de enfermedades) — ✅ EN PROGRESO

### Clases del taxonomía de la app (6)

`hoja_sana`, `mancha_foliar`, `mildiu`, `oidio`, `amarillamiento`, `dano_plaga`

### Dataset real elegido: Kaggle `tahmidmir/pumpkin-leaf-diseases-dataset-from-bangladesh`

2000 imágenes RGB (400 por clase), **5 clases** (no incluye plaga):

| Carpeta del dataset | `claseId` de la app |
|---|---|
| Healthy | `hoja_sana` |
| Downy Mildew | `mildiu` |
| Powdery Mildew | `oidio` |
| Mosaic Disease | `amarillamiento` |
| Bacterial Leaf Spot | `mancha_foliar` |

**`dano_plaga` queda sin cobertura en este modelo v1** — ningún dataset público de hojas de zapallo la incluye bien. La app sigue mostrando esa clase en el catálogo/recomendaciones (Firestore), pero el clasificador nunca la va a predecir hasta sumar imágenes propias etiquetadas como daño por plaga.

### Ruta de entrenamiento: Google Colab (GPU gratis)

Notebook listo: [`mobile_app/tool/entrenar_modelo_colab.ipynb`](mobile_app/tool/entrenar_modelo_colab.ipynb).

1. Descargado localmente, abrir en https://colab.research.google.com (Archivo → Subir cuaderno).
2. Runtime → Change runtime type → **GPU (T4)**.
3. Necesitas tu API token de Kaggle: kaggle.com/settings → API → "Create New Token".
4. Correr las celdas en orden: descarga dataset → mapea carpetas → entrena MobileNetV2 (transfer learning + fine-tuning) → convierte a `.tflite` → descarga `model.tflite` + `labels.txt`.
5. Copiar ambos archivos a `mobile_app/assets/ml/`, reemplazando los placeholders.

> **Por qué Colab y no local:** TensorFlow no soporta Python 3.14 (el instalado en esta máquina) y en Windows perdió soporte GPU nativo desde la versión 2.11 (requiere WSL2). Colab evita ambos problemas sin instalar nada.

### Integración en Flutter (sin cambios de código necesarios)

- `TFLiteService` ya normaliza con `(pixel-127.5)/127.5`, igual que `preprocess_input` de MobileNetV2 usado en el notebook.
- `cargarModelo()` detecta el modelo real automáticamente al reemplazar los assets y deja el modo simulado.
- El orden de `labels.txt` lo define `train_ds.class_names` (alfabético) — el notebook ya lo exporta en el orden correcto, no reordenar a mano.
- Paquete cliente: `tflite_flutter` + preprocesamiento manual (resize 224×224, normalizar).
- `TFLiteService.clasificar(File imagen)` → retorna `List<(String clase, double prob)>` ordenada.
- Umbral: si confianza máxima < 0.55 → mostrar "diagnóstico no concluyente, repita la foto" (pendiente de implementar en `ResultadoDiagnosticoView`).

---

## 9. API REST — OpenWeather

1. Crear cuenta en https://openweathermap.org/api → **API keys** → copiar key (tarda ~1 h en activarse).
2. Endpoints:
   - Clima actual: `https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={KEY}&units=metric&lang=es`
   - Pronóstico 5 días: `https://api.openweathermap.org/data/2.5/forecast?...`
3. La key va en `core/constants/api_keys.dart` (agregado a `.gitignore`).
4. `ClimaRemoteDataSource` usa `http`, mapea a `ClimaModel`, y `ClimaRepositoryImpl` guarda snapshot en colección `clima`.

**Lógica de alerta fúngica:** humedad ≥ 80 % y temp entre 15–25 °C → crear doc en `alertas` + notificación local.

---

## 10. Hardware móvil

| Hardware | Paquete | Uso |
|---|---|---|
| Cámara | `camera` / `image_picker` | Captura de hoja para diagnóstico |
| GPS | `geolocator` | Ubicación de finca, geoetiquetado del diagnóstico, clima local |
| Mapa | `google_maps_flutter` | Visualización de fincas y diagnósticos |

**Google Maps API key (pendiente):** console.cloud.google.com → proyecto `agrotech-19ec5` → APIs & Services → habilitar **Maps SDK for Android** → Credentials → API key → pegar en `android/app/src/main/AndroidManifest.xml` (reemplazar `TU_GOOGLE_MAPS_API_KEY_AQUI`).

**Permisos (`AndroidManifest.xml`):** `CAMERA`, `ACCESS_FINE_LOCATION`, `INTERNET`, `POST_NOTIFICATIONS`.

---

## 11. Aplicación web administrativa (`web_admin/`) — ✅ implementada

Flutter Web (Dart), mismo Firebase (`agrotech-19ec5`). Acceso solo a usuarios en colección `admins`. No replica la Clean Architecture completa de la app móvil (no aplica el examen técnico) — es un solo `AdminRepository` + un `AdminDataViewModel` compartido que las 4 vistas consumen (ver `web_admin/lib/core/`).

### Pantallas (según diseño — sección 13.3)

| # | Pantalla | Función |
|---|---|---|
| 1 | Login admin | Firebase Auth + verificación contra `admins/{uid}` (no está en el prototipo — mismo estilo del login móvil) |
| 2 | Resumen (dashboard) | 4 KPIs + barras apiladas sanas/enfermas 14 días (`fl_chart`) + distribución por clase + tabla recientes + alertas de zona |
| 3 | Diagnósticos | Tabla global con filtros por enfermedad: agricultor, parcela, resultado, confianza, fecha, GPS |
| 4 | Agricultores | Tabla de usuarios: finca, parcelas, # diagnósticos, último acceso |
| 5 | Modelo IA | Métricas del clasificador: accuracy, recall, latencia, tamaño, precisión por clase, estado del despliegue |
| + | Recomendaciones (CRUD) | Extra: editar recomendaciones que consume la app móvil |
| + | Alertas | Extra: emitir alerta general a agricultores (crea docs en `alertas`) |

### Correr localmente

```powershell
cd web_admin
flutter run -d chrome
```

### Despliegue — pendiente

```powershell
cd web_admin
flutter build web
cd ..
firebase deploy --only hosting
```

(`firebase.json` en la raíz ya apunta `hosting.public` a `web_admin/build/web`.)

---

## 12. Despliegue móvil (Play Store)

1. `flutter build appbundle --release` con firma propia:
   - `keytool -genkey -v -keystore sigchos-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sigchos`
   - Configurar `android/key.properties` + `build.gradle`.
2. Play Console (cuenta en verificación): crear app → subir AAB a **prueba interna** → agregar testers → link de instalación.
3. **Plan B mientras se verifica la cuenta:** `flutter build apk --release` → APK firmado instalado en el celular (cumple "instalación en celular").

---

## 13. Diseño (Claude Design) — ✅ VERIFICADO

Bundle importado en `sigchos-agrotech/project/`:
- `Sigchos Agrotech.dc.html` — app móvil (13 pantallas prototipadas)
- `Sigchos Agrotech Admin.dc.html` — panel web administrativo (4 vistas)

### 13.1 Tokens de diseño (extraídos del prototipo → `core/theme/app_theme.dart`)

**Tipografía (Google Fonts):**
| Uso | Fuente |
|---|---|
| Títulos / display / botones | Space Grotesk (400–700) |
| Cuerpo | DM Sans (400–700) |
| Etiquetas uppercase, datos numéricos, % confianza | DM Mono (400–500) |

**Paleta:**
| Token | Valor | Uso |
|---|---|---|
| `verdeOscuro` | `#225C3B` | Botones primarios, header inicio, tab activo |
| `verdeMedio` | `#2E7D4F` | CTA "Nuevo diagnóstico", acentos, links |
| `verdeSidebar` | `#1C3A29` | Sidebar del admin |
| `naranja` | `#E08A2B` | FAB cámara, logo (gota rotada 45°), spinner IA |
| `fondoApp` | `#F4F1E9` | Fondo de pantallas móvil |
| `fondoAdmin` | `#F1EEE5` | Fondo del panel web |
| `card` | `#FFFFFF` borde `#E7E3D8` | Tarjetas |
| `textoPrimario` | `#1B2D22` | Títulos y texto principal |
| `textoSecundario` | `#717A70` | Subtítulos, metadatos |
| `textoDeshabilitado` | `#9AA197` | Tabs inactivos, placeholders |
| `severidadAlta` | `#C9533A` bg `#FBE9E4` | Mancha foliar, mildiú |
| `severidadMedia` | `#DBA42E` bg `#FBF1DE` | Oídio, amarillamiento, plaga |
| `sano` | `#2E9E5E` bg `#E4F0E6` | Hoja sana |
| `alertaAmbar` | texto `#8A5A12` bg `#FBF3E6` borde `#F0DCBE` | Alertas de zona / riesgo fúngico |
| `fondoCamara` | `#111613` | Pantallas captura y analizando (modo oscuro) |

**Gradientes:** login `168deg #225C3B → #2E7D4F 52% → #256340`; card clima `160deg #2E7D4F → #225C3B`.

**Colores por clase (gráficos admin):** sana `#2E9E5E`, mancha `#C9533A`, mildiú `#B5562F`, oídio `#DBA42E`, amarillamiento `#C9A227`, plaga `#A8743B`.

**Formas:** cards radio 16–20 · inputs altura 52 radio 14 · botón primario altura 54–56 radio 15–16 · chips/filtros radio 100 · tab bar flotante blanca radio 22 con FAB naranja central (52 px, elevado −18).

### 13.2 Pantallas móviles definidas en el prototipo

Login (gradiente verde) · Inicio (header verde + clima + CTA diagnóstico + últimos dx + alerta de zona) · Captura cámara (marco naranja de encuadre, fondo oscuro) · Analizando (spinner + "Modelo TensorFlow Lite procesando…") · Resultado diagnóstico (foto geoetiquetada, badge severidad, anillo % confianza, top-3 "otras probabilidades") · Recomendaciones (numeradas 1-4 por enfermedad) · Historial (chips de filtro) · Mapa de zonas afectadas (focos + casos) · Clima (card gradiente + riesgo fúngico + pronóstico) · Mis fincas · Registrar parcela (paso 1/2, mini-mapa GPS) · Registrar cultivo (paso 2/2, chips variedad Macre/Loche/Italiano) · Tab bar (Inicio·Historial·📷·Mapa·Clima).

**Faltan en el prototipo (diseñar siguiendo el mismo estilo):** Registro de usuario (existe link "Regístrate" en login), formulario de finca, perfil.

**Contenido real en el prototipo:** las 6 enfermedades traen nombre científico y 4 recomendaciones cada una (Cercospora citrullina, Pseudoperonospora cubensis, Podosphaera xanthii…) — usar ese texto para poblar la colección `recomendaciones`.

### 13.3 Vistas del admin definidas en el prototipo

Sidebar fija verde `#1C3A29` con: Resumen · Diagnósticos (badge contador) · Agricultores · Modelo IA · card "Servicios activos" · perfil admin. Header con fecha y botón "Exportar reporte".

1. **Resumen:** 4 KPIs (diagnósticos totales, % hojas enfermas, agricultores activos, confianza media IA) + gráfico de barras apiladas sanas/enfermas 14 días + distribución por clase + tabla de recientes + alertas de zona + clima Sigchos.
2. **Diagnósticos:** chips de filtro por enfermedad + tabla (agricultor, parcela, resultado con badge, confianza, fecha, GPS).
3. **Agricultores:** tabla (avatar iniciales, correo, finca, parcelas, # diagnósticos, último acceso).
4. **Modelo IA:** KPIs (accuracy, recall, latencia, tamaño) + precisión por clase + estado del despliegue + card reentrenamiento.

---

## 14. Dependencias (`pubspec.yaml` móvil)

```yaml
dependencies:
  flutter: { sdk: flutter }
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x        # o cloudinary vía http si no hay Blaze
  provider: ^6.x
  http: ^1.x
  geolocator: ^13.x
  google_maps_flutter: ^2.x
  image_picker: ^1.x
  camera: ^0.11.x
  tflite_flutter: ^0.11.x
  image: ^4.x                    # preprocesamiento para TFLite
  flutter_local_notifications: ^18.x
  fl_chart: ^0.69.x
  intl: ^0.19.x
dev_dependencies:
  flutter_lints: ^5.x
```

---

## 15. Validaciones de formularios

- **Login:** email formato válido, contraseña ≥ 6 caracteres, mensajes de error de Firebase traducidos.
- **Registro:** nombre no vacío, cédula ecuatoriana 10 dígitos (algoritmo de verificación), teléfono 10 dígitos, confirmación de contraseña.
- **Finca/Parcela/Cultivo:** nombre requerido, área numérica > 0, fechas coherentes (siembra ≤ hoy).
- **Diagnóstico:** imagen obligatoria antes de analizar.
- Todo con `Form` + `GlobalKey<FormState>` + `validator:` en `core/utils/validators.dart`.

---

## 16. Plan de trabajo por fases

| Fase | Contenido | Entregable verificable |
|---|---|---|
| **F1 — Setup** | Crear proyecto Firebase (sección 7), `flutter create mobile_app`, estructura Clean Architecture, tema, rutas | App corre con splash + tema |
| **F2 — Auth** | Login, registro, AuthViewModel, validaciones, sesión persistente | Login/registro funcionales contra Firebase |
| **F3 — CRUD agro** | Fincas → parcelas → cultivos (Firestore + GPS en finca) | CRUD completo navegable |
| **F4 — IA** | Modelo Teachable Machine, TFLiteService, captura cámara, pantalla resultado, guardar diagnóstico + imagen | Foto → diagnóstico con % confianza |
| **F5 — Clima/Mapa** | OpenWeather + geolocator, pantalla clima, alerta fúngica, mapa de fincas | Clima real por GPS + mapa con marcadores |
| **F6 — Historial/extras** | Historial con filtros, detalle, recomendaciones, notificaciones, estadísticas | Flujo completo end-to-end |
| **F7 — Web admin** | `web_admin/` completo (sección 11) + Firebase Hosting | URL pública del panel |
| **F8 — Cierre** | Reglas de seguridad definitivas, APK firmado, Play Console prueba interna, README con capturas | APK instalado en celular |

Orden de dependencias: F1 → F2 → F3 → F4 (F5 y F6 pueden intercalarse) → F7 → F8.

---

## 17. Checklist final antes de la defensa

- [ ] APK instalado en celular físico
- [ ] Login + registro funcionan con datos reales
- [ ] Foto de hoja → diagnóstico con % de confianza
- [ ] Diagnóstico guardado en Firestore con imagen
- [ ] Clima real según GPS del dispositivo
- [ ] Mapa con marcadores
- [ ] Historial y recomendaciones visibles
- [ ] Notificación de alerta demostrable
- [ ] Web admin desplegada con dashboard y monitoreo
- [ ] Código organizado: domain/data/presentation en cada feature
- [ ] Ningún ViewModel accede a Firebase directo (siempre vía usecase → repository)
- [ ] Reglas de Firestore aplicadas
- [ ] API keys fuera del repositorio público
