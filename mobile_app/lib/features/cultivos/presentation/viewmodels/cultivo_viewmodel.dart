import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../services/notification_service.dart';
import '../../domain/entities/cultivo_entity.dart';
import '../../domain/usecases/crear_cultivo_usecase.dart';
import '../../domain/usecases/obtener_cultivos_usecase.dart';

class CultivoViewModel extends ChangeNotifier {
  final CrearCultivoUseCase _crearCultivoUseCase;
  final ObtenerCultivosPorUsuarioUseCase _obtenerCultivosPorUsuarioUseCase;
  final NotificationService? _notificationService;

  CultivoViewModel({
    required CrearCultivoUseCase crearCultivoUseCase,
    required ObtenerCultivosPorUsuarioUseCase
        obtenerCultivosPorUsuarioUseCase,
    NotificationService? notificationService,
  })  : _crearCultivoUseCase = crearCultivoUseCase,
        _obtenerCultivosPorUsuarioUseCase = obtenerCultivosPorUsuarioUseCase,
        _notificationService = notificationService;

  List<CultivoEntity> cultivos = [];
  bool isGuardando = false;
  String? errorMessage;
  StreamSubscription<List<CultivoEntity>>? _subscription;

  void escucharCultivosDeUsuario(String usuarioId) {
    _subscription?.cancel();
    _subscription =
        _obtenerCultivosPorUsuarioUseCase(usuarioId).listen((lista) {
      cultivos = lista;
      notifyListeners();
    });
  }

  Future<bool> crearCultivo({
    required String parcelaId,
    required String usuarioId,
    required String variedad,
    required DateTime fechaSiembra,
    required int plantasEstimadas,
  }) async {
    isGuardando = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _crearCultivoUseCase(CultivoEntity(
        id: '',
        parcelaId: parcelaId,
        usuarioId: usuarioId,
        variedad: variedad,
        fechaSiembra: fechaSiembra,
        plantasEstimadas: plantasEstimadas,
      ));
      await _notificationService?.programarRecordatorioSemanal();
      return true;
    } on Failure catch (f) {
      errorMessage = f.message;
      return false;
    } finally {
      isGuardando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
