import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones locales de la app: alerta de riesgo fúngico (clima),
/// resultado de diagnóstico y recordatorio semanal de revisión de cultivos.
/// No depende de servidor push — todo se dispara desde el propio dispositivo
/// a partir de datos ya obtenidos (sin llamadas extra a APIs externas).
class NotificationService {
  static const _canalAlertas = AndroidNotificationDetails(
    'alertas_clima',
    'Alertas de clima',
    channelDescription:
        'Avisos de condiciones que favorecen enfermedades foliares',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _canalDiagnostico = AndroidNotificationDetails(
    'diagnosticos',
    'Diagnósticos',
    channelDescription: 'Resultado del análisis de una hoja',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _canalRecordatorios = AndroidNotificationDetails(
    'recordatorios',
    'Recordatorios',
    channelDescription: 'Recordatorio periódico de revisión de cultivos',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> inicializar() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> alertaRiesgoFungico({
    required double temperatura,
    required int humedad,
  }) {
    return _plugin.show(
      1001,
      'Riesgo de enfermedad foliar',
      'Humedad $humedad% y ${temperatura.round()}°C: condiciones que '
          'favorecen mildiú y mancha foliar. Revisa tus cultivos.',
      const NotificationDetails(android: _canalAlertas),
    );
  }

  Future<void> resultadoDiagnostico({
    required String enfermedad,
    required int confianzaPorcentaje,
  }) {
    return _plugin.show(
      1002,
      'Diagnóstico listo',
      '$enfermedad detectada con $confianzaPorcentaje% de confianza.',
      const NotificationDetails(android: _canalDiagnostico),
    );
  }

  /// Idempotente: reprograma el mismo id, seguro de llamar en cada cultivo creado.
  Future<void> programarRecordatorioSemanal() {
    return _plugin.periodicallyShow(
      1003,
      'Revisa tus cultivos',
      'Captura una nueva hoja para mantener el historial de diagnósticos al día.',
      RepeatInterval.weekly,
      const NotificationDetails(android: _canalRecordatorios),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
