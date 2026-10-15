import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

import '../modelos/alarma.dart';

class AlarmaServicio {
  static Stream<AlarmSettings>? _ringBroadcast;
  static StreamSubscription<AlarmSettings>? _ringSub;

  static Stream<AlarmSettings> get onRing {
    _ringBroadcast ??= Alarm.ringStream.stream.asBroadcastStream();
    return _ringBroadcast!;
  }

  static void initListener() {
    _ringSub?.cancel();
    _ringSub = onRing.listen((settings) {});
  }

  static int _safeIntId(String id) {
    final raw = id.length >= 8 ? id.substring(id.length - 8) : id;
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? (id.hashCode & 0x7fffffff);
  }

  Future<void> programarAlarmaNativa(Alarma alarma) async {
    final estadoAlarma = await Permission.scheduleExactAlarm.request();
    if (estadoAlarma.isDenied || estadoAlarma.isPermanentlyDenied) {
      openAppSettings();
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

  Future<void> cancelarAlarmaNativa(String id) async {
    final intId = _safeIntId(id);
    await Alarm.stop(intId);
  }
}
