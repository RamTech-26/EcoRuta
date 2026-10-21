import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

import '../modelos/alarma.dart';

/// Programa y cancela las alarmas del sistema con el paquete `alarm`.
///
/// Guardarlas en la base es tarea de `AlarmaRepositorio`.
class AlarmaServicio {
  static Stream<AlarmSettings>? _ringBroadcast;
  static StreamSubscription<AlarmSettings>? _ringSub;

  /// Avisos de las alarmas que empiezan a sonar.
  ///
  /// Comparte el stream del plugin como broadcast para que lo puedan
  /// escuchar varios a la vez (main.dart y los ViewModels) sin el error
  /// "Stream has already been listened to".
  static Stream<AlarmSettings> get onRing {
    _ringBroadcast ??= Alarm.ringStream.stream.asBroadcastStream();
    return _ringBroadcast!;
  }

  /// Deja un oyente fijo del stream. Se llama una sola vez, desde main.dart.
  static void initListener() {
    _ringSub?.cancel();
    _ringSub = onRing.listen((settings) {
      // TODO(grupo): abrir una pantalla de "alarma sonando".
    });
  }

  /// Convierte el id de texto de la alarma en el `int` que pide el plugin.
  ///
  /// El id es un timestamp en milisegundos: se usan sus últimos 8 dígitos
  /// para que entre en un int de 32 bits. Si no tiene dígitos, se usa el hash.
  static int _safeIntId(String id) {
    final raw = id.length >= 8 ? id.substring(id.length - 8) : id;
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? (id.hashCode & 0x7fffffff);
  }

  /// Programa [alarma] en el sistema para su próxima fecha.
  ///
  /// Si falta el permiso de alarmas exactas o de notificaciones, no la programa.
  Future<void> programarAlarmaNativa(Alarma alarma) async {
    final estadoAlarma = await Permission.scheduleExactAlarm.request();
    if (estadoAlarma.isDenied || estadoAlarma.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    final estadoNotificaciones = await Permission.notification.request();
    if (estadoNotificaciones.isDenied ||
        estadoNotificaciones.isPermanentlyDenied) {
      return;
    }

    final intId = _safeIntId(alarma.id);
    final fechaObjetivo = alarma.obtenerProximaFecha();

    final alarmSettings = AlarmSettings(
      id: intId,
      dateTime: fechaObjetivo,
      assetAudioPath: 'assets/alarma.mp3',
      loopAudio: alarma.loopAudio,
      vibrate: alarma.vibrar,
      volume: alarma.volumenPersonalizado ? alarma.volumen : null,
      fadeDuration: 5.0,
      notificationSettings: const NotificationSettings(
        title: 'EcoRuta 2026 - Alarma de viaje',
        body: 'Es hora de salir hacia tu lugar frecuente.',
        stopButton: 'Detener',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Cancela la alarma [id] programada en el sistema.
  Future<void> cancelarAlarmaNativa(String id) async {
    final intId = _safeIntId(id);
    await Alarm.stop(intId);
  }
}
