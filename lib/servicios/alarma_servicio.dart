import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import '../modelos/alarma.dart';

class AlarmaServicio {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- FIX 1: BROADCAST CENTRALIZADO (PASO 3) ---
  static Stream<AlarmSettings>? _ringBroadcast;
  static StreamSubscription<AlarmSettings>? _ringSub;

  // Este es el stream que van a usar los ViewModels
  static Stream<AlarmSettings> get onRing {
    _ringBroadcast??= Alarm.ringStream.stream.asBroadcastStream();
    return _ringBroadcast!;
  }

  // Llamalo UNA sola vez desde main.dart
  static void initListener() {
    _ringSub?.cancel();
    _ringSub = onRing.listen((settings) {
      print('[Alarm] Sonando id: ${settings.id}');
      // Acá podés navegar a tu pantalla de alarma sonando
    });
  }

  // --- FIX 2: ID SEGURO (Truco 3 del video) ---
  static int _safeIntId(String id) {
    final raw = id.length >= 8? id.substring(id.length - 8) : id;
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly)?? (id.hashCode & 0x7fffffff);
  }

  Future<List<Alarma>> obtenerTodas() async {
    final db = await _dbHelper.database;
    final res = await db.query('alarmas', orderBy: 'orden ASC');
    return res.map((e) => Alarma.fromMap(e)).toList();
  }

  Future<void> guardar(Alarma alarma) async {
    final db = await _dbHelper.database;
    await db.insert(
      'alarmas',
      alarma.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (alarma.activa) {
      await programarAlarmaNativa(alarma);
    } else {
      await cancelarAlarmaNativa(alarma.id);
    }
  }

  Future<void> eliminar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('alarmas', where: 'id =?', whereArgs: [id]);
    await cancelarAlarmaNativa(id);
  }

  Future<void> programarAlarmaNativa(Alarma alarma) async {
    final estadoAlarma = await Permission.scheduleExactAlarm.request();
    if (estadoAlarma.isDenied || estadoAlarma.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final estadoNotificaciones = await Permission.notification.request();
    if (estadoNotificaciones.isDenied || estadoNotificaciones.isPermanentlyDenied) {
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
      volume: alarma.volumenPersonalizado? alarma.volumen : null,
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

  Future<void> actualizarOrden(List<Alarma> alarmas) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var i = 0; i < alarmas.length; i++) {
      batch.update(
        'alarmas',
        {'orden': i},
        where: 'id =?',
        whereArgs: [alarmas[i].id],
      );
    }
    await batch.commit();
  }
}