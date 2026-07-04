import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/tflite_service.dart';

// Auth
import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/actualizar_perfil_usecase.dart';
import 'features/auth/domain/usecases/login_google_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/obtener_usuario_actual_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

// Fincas
import 'features/fincas/data/datasources/finca_firestore_datasource.dart';
import 'features/fincas/data/repositories/finca_repository_impl.dart';
import 'features/fincas/domain/usecases/crear_finca_usecase.dart';
import 'features/fincas/domain/usecases/obtener_fincas_usecase.dart';
import 'features/fincas/presentation/viewmodels/finca_viewmodel.dart';

// Parcelas
import 'features/parcelas/data/datasources/parcela_firestore_datasource.dart';
import 'features/parcelas/data/repositories/parcela_repository_impl.dart';
import 'features/parcelas/domain/usecases/crear_parcela_usecase.dart';
import 'features/parcelas/domain/usecases/obtener_parcelas_usecase.dart';
import 'features/parcelas/presentation/viewmodels/parcela_viewmodel.dart';

// Cultivos
import 'features/cultivos/data/datasources/cultivo_firestore_datasource.dart';
import 'features/cultivos/data/repositories/cultivo_repository_impl.dart';
import 'features/cultivos/domain/usecases/crear_cultivo_usecase.dart';
import 'features/cultivos/domain/usecases/obtener_cultivos_usecase.dart';
import 'features/cultivos/presentation/viewmodels/cultivo_viewmodel.dart';

// Diagnóstico
import 'features/diagnostico/data/datasources/diagnostico_firestore_datasource.dart';
import 'features/diagnostico/data/repositories/diagnostico_repository_impl.dart';
import 'features/diagnostico/domain/usecases/clasificar_hoja_usecase.dart';
import 'features/diagnostico/domain/usecases/crear_diagnostico_usecase.dart';
import 'features/diagnostico/domain/usecases/obtener_historial_usecase.dart';
import 'features/diagnostico/presentation/viewmodels/diagnostico_viewmodel.dart';

// Recomendaciones
import 'features/recomendaciones/data/datasources/recomendacion_firestore_datasource.dart';
import 'features/recomendaciones/data/repositories/recomendacion_repository_impl.dart';
import 'features/recomendaciones/domain/usecases/obtener_recomendaciones_usecase.dart';
import 'features/recomendaciones/presentation/viewmodels/recomendacion_viewmodel.dart';

// Historial
import 'features/historial/presentation/viewmodels/historial_viewmodel.dart';

// Clima
import 'features/clima/data/datasources/openweather_datasource.dart';
import 'features/clima/data/repositories/clima_repository_impl.dart';
import 'features/clima/domain/usecases/obtener_clima_actual_usecase.dart';
import 'features/clima/domain/usecases/obtener_pronostico_usecase.dart';
import 'features/clima/presentation/viewmodels/clima_viewmodel.dart';

// Mapa
import 'features/mapa/presentation/viewmodels/mapa_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');

  final notificationService = NotificationService();
  await notificationService.inicializar();

  // --- Composición manual de dependencias (Clean Architecture) ---
  // Auth
  final authRepository = AuthRepositoryImpl(AuthFirebaseDataSource());

  // Fincas
  final fincaRepository = FincaRepositoryImpl(FincaFirestoreDataSource());
  final obtenerFincasUseCase = ObtenerFincasUseCase(fincaRepository);

  // Parcelas
  final parcelaRepository = ParcelaRepositoryImpl(ParcelaFirestoreDataSource());

  // Cultivos
  final cultivoRepository = CultivoRepositoryImpl(CultivoFirestoreDataSource());

  // Diagnóstico (IA + Storage + Firestore)
  final tfliteService = TFLiteService();
  await tfliteService.cargarModelo();
  final diagnosticoRepository = DiagnosticoRepositoryImpl(
    dataSource: DiagnosticoFirestoreDataSource(),
    tfliteService: tfliteService,
    storageService: StorageService(),
  );
  final obtenerHistorialUseCase = ObtenerHistorialUseCase(diagnosticoRepository);

  // Recomendaciones
  final recomendacionRepository =
      RecomendacionRepositoryImpl(RecomendacionFirestoreDataSource());

  // Clima
  final climaRepository = ClimaRepositoryImpl(OpenWeatherDataSource());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            loginUseCase: LoginUseCase(authRepository),
            loginGoogleUseCase: LoginGoogleUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            obtenerUsuarioActualUseCase:
                ObtenerUsuarioActualUseCase(authRepository),
            actualizarPerfilUseCase:
                ActualizarPerfilUseCase(authRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FincaViewModel(
            crearFincaUseCase: CrearFincaUseCase(fincaRepository),
            actualizarFincaUseCase: ActualizarFincaUseCase(fincaRepository),
            obtenerFincasUseCase: obtenerFincasUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ParcelaViewModel(
            crearParcelaUseCase: CrearParcelaUseCase(parcelaRepository),
            actualizarParcelaUseCase:
                ActualizarParcelaUseCase(parcelaRepository),
            obtenerParcelasPorFincaUseCase:
                ObtenerParcelasPorFincaUseCase(parcelaRepository),
            obtenerParcelasPorUsuarioUseCase:
                ObtenerParcelasPorUsuarioUseCase(parcelaRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CultivoViewModel(
            crearCultivoUseCase: CrearCultivoUseCase(cultivoRepository),
            obtenerCultivosPorUsuarioUseCase:
                ObtenerCultivosPorUsuarioUseCase(cultivoRepository),
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DiagnosticoViewModel(
            clasificarHojaUseCase: ClasificarHojaUseCase(diagnosticoRepository),
            crearDiagnosticoUseCase:
                CrearDiagnosticoUseCase(diagnosticoRepository),
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecomendacionViewModel(
            obtenerRecomendacionesUseCase:
                ObtenerRecomendacionesUseCase(recomendacionRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistorialViewModel(
            obtenerHistorialUseCase: obtenerHistorialUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ClimaViewModel(
            obtenerClimaActualUseCase: ObtenerClimaActualUseCase(climaRepository),
            obtenerPronosticoUseCase: ObtenerPronosticoUseCase(climaRepository),
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MapaViewModel(
            obtenerFincasUseCase: obtenerFincasUseCase,
            obtenerHistorialUseCase: obtenerHistorialUseCase,
          ),
        ),
      ],
      child: const SigchosApp(),
    ),
  );
}
