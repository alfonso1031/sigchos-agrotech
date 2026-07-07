import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../diagnostico/domain/entities/diagnostico_entity.dart';
import '../../../diagnostico/domain/usecases/eliminar_diagnostico_usecase.dart';
import '../../../diagnostico/domain/usecases/obtener_historial_usecase.dart';

/// Reutiliza el caso de uso del feature `diagnostico`: el historial es,
/// conceptualmente, una vista filtrada sobre los mismos diagnósticos.
class HistorialViewModel extends ChangeNotifier {
  final ObtenerHistorialUseCase _obtenerHistorialUseCase;
  final EliminarDiagnosticoUseCase _eliminarDiagnosticoUseCase;
  HistorialViewModel({
    required ObtenerHistorialUseCase obtenerHistorialUseCase,
    required EliminarDiagnosticoUseCase eliminarDiagnosticoUseCase,
  })  : _obtenerHistorialUseCase = obtenerHistorialUseCase,
        _eliminarDiagnosticoUseCase = eliminarDiagnosticoUseCase;

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

  /// Elimina un diagnóstico. Quita el ítem de la lista al instante (optimista)
  /// y lo restaura si el borrado remoto falla. Relanza el error para que la
  /// vista muestre un mensaje.
  Future<void> eliminar(DiagnosticoEntity diagnostico) async {
    final indice = _todos.indexWhere((d) => d.id == diagnostico.id);
    if (indice != -1) {
      _todos.removeAt(indice);
      notifyListeners();
    }
    try {
      await _eliminarDiagnosticoUseCase(diagnostico);
    } catch (_) {
      if (indice != -1) {
        _todos.insert(indice, diagnostico);
        notifyListeners();
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
