import 'package:flutter/foundation.dart';
import '../models/admin_models.dart';
import '../services/admin_repository.dart';

class DiagnosticoEnriquecido {
  final DiagnosticoDoc doc;
  final String agricultor;
  final String parcela;
  const DiagnosticoEnriquecido(this.doc, this.agricultor, this.parcela);
}

class AgricultorResumen {
  final UsuarioDoc usuario;
  final String finca;
  final int parcelas;
  final int diagnosticos;
  final DateTime? ultimoDiagnostico;

  const AgricultorResumen({
    required this.usuario,
    required this.finca,
    required this.parcelas,
    required this.diagnosticos,
    required this.ultimoDiagnostico,
  });
}

/// Carga todas las colecciones una vez y expone proyecciones ya combinadas
/// (join en memoria) para las vistas Resumen / Diagnósticos / Agricultores.
class AdminDataViewModel extends ChangeNotifier {
  final AdminRepository _repository;
  AdminDataViewModel({AdminRepository? repository})
      : _repository = repository ?? AdminRepository();

  bool isLoading = false;
  String? errorMessage;

  List<UsuarioDoc> _usuarios = [];
  List<FincaDoc> _fincas = [];
  List<ParcelaDoc> _parcelas = [];
  List<CultivoDoc> _cultivos = [];
  List<DiagnosticoDoc> _diagnosticos = [];

  Future<void> cargar() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final resultados = await Future.wait([
        _repository.obtenerUsuarios(),
        _repository.obtenerFincas(),
        _repository.obtenerParcelas(),
        _repository.obtenerCultivos(),
        _repository.obtenerDiagnosticos(),
      ]);
      _usuarios = resultados[0] as List<UsuarioDoc>;
      _fincas = resultados[1] as List<FincaDoc>;
      _parcelas = resultados[2] as List<ParcelaDoc>;
      _cultivos = resultados[3] as List<CultivoDoc>;
      _diagnosticos = resultados[4] as List<DiagnosticoDoc>;
    } catch (e) {
      errorMessage = 'No se pudieron cargar los datos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _nombreUsuario(String uid) => _usuarios
      .firstWhere((u) => u.uid == uid, orElse: () => UsuarioDoc(uid: uid, nombre: '—', correo: ''))
      .nombre;

  String _nombreParcelaDeCultivo(String cultivoId) {
    final cultivo = _cultivos.where((c) => c.id == cultivoId);
    if (cultivo.isEmpty) return '—';
    final parcela = _parcelas.where((p) => p.id == cultivo.first.parcelaId);
    return parcela.isEmpty ? '—' : parcela.first.nombre;
  }

  List<DiagnosticoEnriquecido> get diagnosticos => _diagnosticos
      .map((d) => DiagnosticoEnriquecido(
            d,
            _nombreUsuario(d.usuarioId),
            _nombreParcelaDeCultivo(d.cultivoId),
          ))
      .toList();

  List<AgricultorResumen> get agricultores => _usuarios.map((u) {
        final fincasDe = _fincas.where((f) => f.usuarioId == u.uid).toList();
        final parcelasDe = _parcelas.where((p) => p.usuarioId == u.uid).length;
        final diagDe = _diagnosticos.where((d) => d.usuarioId == u.uid).toList();
        DateTime? ultimo;
        for (final d in diagDe) {
          if (ultimo == null || d.fecha.isAfter(ultimo)) ultimo = d.fecha;
        }
        return AgricultorResumen(
          usuario: u,
          finca: fincasDe.isEmpty ? '—' : fincasDe.first.nombre,
          parcelas: parcelasDe,
          diagnosticos: diagDe.length,
          ultimoDiagnostico: ultimo,
        );
      }).toList();

  int get totalDiagnosticos => _diagnosticos.length;

  double get porcentajeEnfermas => _diagnosticos.isEmpty
      ? 0
      : _diagnosticos.where((d) => d.enfermedad != 'hoja_sana').length /
          _diagnosticos.length;

  int get agricultoresActivos => _usuarios.length;

  double get confianzaMedia => _diagnosticos.isEmpty
      ? 0
      : _diagnosticos.map((d) => d.confianza).reduce((a, b) => a + b) /
          _diagnosticos.length;

  Map<String, int> get distribucionPorClase {
    final mapa = <String, int>{};
    for (final d in _diagnosticos) {
      mapa[d.enfermedad] = (mapa[d.enfermedad] ?? 0) + 1;
    }
    return mapa;
  }

  /// Conteo de diagnósticos sanos/enfermos por día para los últimos [dias] días.
  List<({DateTime dia, int sanas, int enfermas})> chartDiario({int dias = 14}) {
    final hoy = DateTime.now();
    final resultado = <({DateTime dia, int sanas, int enfermas})>[];
    for (var i = dias - 1; i >= 0; i--) {
      final dia = DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: i));
      final delDia = _diagnosticos.where((d) =>
          d.fecha.year == dia.year && d.fecha.month == dia.month && d.fecha.day == dia.day);
      resultado.add((
        dia: dia,
        sanas: delDia.where((d) => d.enfermedad == 'hoja_sana').length,
        enfermas: delDia.where((d) => d.enfermedad != 'hoja_sana').length,
      ));
    }
    return resultado;
  }

  /// Parcelas con >=2 diagnósticos con daño en los últimos 7 días.
  List<({String parcela, String enfermedad, int casos})> alertasDeZona() {
    final limite = DateTime.now().subtract(const Duration(days: 7));
    final conteo = <String, int>{};
    for (final d in _diagnosticos) {
      if (d.enfermedad == 'hoja_sana' || d.fecha.isBefore(limite)) continue;
      final parcela = _nombreParcelaDeCultivo(d.cultivoId);
      final clave = '$parcela|${d.enfermedad}';
      conteo[clave] = (conteo[clave] ?? 0) + 1;
    }
    final resultado = conteo.entries
        .where((e) => e.value >= 2)
        .map((e) {
          final partes = e.key.split('|');
          return (parcela: partes[0], enfermedad: partes[1], casos: e.value);
        })
        .toList()
      ..sort((a, b) => b.casos.compareTo(a.casos));
    return resultado.take(3).toList();
  }
}
