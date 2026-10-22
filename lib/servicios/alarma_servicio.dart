import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

import '../modelos/alarma.dart';

/// Si las alarmas pueden sonar, según los permisos del sistema.
enum EstadoPermisoAlarma { concedido, faltaPermiso, negadoParaSiempre }

/// Programa y cancela las alarmas del sistema con el paquete `alarm`.
///
/// Guardarlas en la base es tarea de `AlarmaRepositorio`. Este servicio
/// no le muestra nada al usuario: qué hacer si falta un permiso lo
/// decide la vista.
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
    _ringSub = onRing.listen((settings) {});
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

  /// Si [settings] es la alarma nativa que corresponde a [alarma].
  bool esLaMisma(Alarma alarma, AlarmSettings settings) =>
      _safeIntId(alarma.id) == settings.id;

  /// Revisa los permisos de alarmas exactas y notificaciones sin pedirlos.
  Future<EstadoPermisoAlarma> revisarPermisos() async {
    final alarmas = await Permission.scheduleExactAlarm.status;
    final notificaciones = await Permission.notification.status;
    return _estadoPermiso(alarmas, notificaciones);
  }

  /// Pide los permisos que falten.
  ///
  /// Se llama solo después de explicarle al usuario para qué se necesitan.
  Future<EstadoPermisoAlarma> pedirPermisos() async {
    final notificaciones = await Permission.notification.request();
    final alarmas = await Permission.scheduleExactAlarm.request();
    return _estadoPermiso(alarmas, notificaciones);
  }

  /// Abre los ajustes de la app (para un permiso negado para siempre).
  Future<bool> abrirAjustes() => openAppSettings();

  EstadoPermisoAlarma _estadoPermiso(
    PermissionStatus alarmas,
    PermissionStatus notificaciones,
  ) {
    if (alarmas.isGranted && notificaciones.isGranted) {
      return EstadoPermisoAlarma.concedido;
    }
    if (alarmas.isPermanentlyDenied || notificaciones.isPermanentlyDenied) {
      return EstadoPermisoAlarma.negadoParaSiempre;
    }
    return EstadoPermisoAlarma.faltaPermiso;
  }

  /// Programa [alarma] en el sistema para su próxima fecha.
  ///
  /// No pide permisos: antes de activar una alarma, la vista se asegura
  /// de tenerlos con [revisarPermisos] y [pedirPermisos].
  Future<void> programarAlarmaNativa(Alarma alarma) async {
    final alarmSettings = AlarmSettings(
      id: _safeIntId(alarma.id),
      dateTime: alarma.obtenerProximaFecha(),
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
    await Alarm.stop(_safeIntId(id));
  }
}
