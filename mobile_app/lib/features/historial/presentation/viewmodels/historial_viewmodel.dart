import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../../../diagnostico/domain/usecases/obtener_historial_usecase.dart';

/// Reutiliza el caso de uso del feature `diagnostico`: el historial es,
/// conceptualmente, una vista filtrada sobre los mismos diagnósticos.
class HistorialViewModel extends ChangeNotifier {
  final ObtenerHistorialUseCase _obtenerHistorialUseCase;
  HistorialViewModel({required ObtenerHistorialUseCase obtenerHistorialUseCase})
      : _obtenerHistorialUseCase = obtenerHistorialUseCase;

  List<DiagnosticoEntity> _todos = [];
  String? filtroClase; // null = "Todos"
  bool isLoading = false;
  StreamSubscription<List<DiagnosticoEntity>>? _subscription;

  List<DiagnosticoEntity> get diagnosticos => filtroClase == null
      ? _todos
      : _todos.where((d) => d.enfermedad == filtroClase).toList();

  void escuchar(String usuarioId) {
    isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _obtenerHistorialUseCase(usuarioId).listen((lista) {
      _todos = lista;
      isLoading = false;
      notifyListeners();
    });
  }

  void filtrarPor(String? claseId) {
    filtroClase = claseId;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
