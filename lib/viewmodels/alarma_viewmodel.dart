import 'dart:async';
import 'package:flutter/foundation.dart';
import '../modelos/alarma.dart';
import '../servicios/alarma_servicio.dart';

class AlarmaViewModel extends ChangeNotifier {
  final AlarmaServicio _servicio = AlarmaServicio();
  List<Alarma> _alarmas = [];
  bool _cargando = false;
  String? _error;
  StreamSubscription? _ringSub; // <- NUEVO

  List<Alarma> get alarmas => _alarmas;
  bool get cargando => _cargando;
  String? get error => _error;

  AlarmaViewModel() {
    _escucharEventosDeAlarma();
  }

  Future<void> cargarAlarmas() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _alarmas = await _servicio.obtenerTodas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // --- FIX DEL STREAM ---
  void _escucharEventosDeAlarma() {
    _ringSub?.cancel();
    // Escuchamos el broadcast del servicio, NO el stream directo del plugin
    _ringSub = AlarmaServicio.onRing.listen((alarmSettings) async {
      final alarmasGuardadas = await _servicio.obtenerTodas();
      for (var a in alarmasGuardadas) {
        if (a.activa) {
          await _servicio.programarAlarmaNativa(a);
        }
      }
      _alarmas = alarmasGuardadas;
      notifyListeners();
    });
  }

  Future<void> guardarAlarma(Alarma alarma) async {
    await _servicio.guardar(alarma);
    await cargarAlarmas();
  }

  Future<void> alternarActivacion(Alarma alarma, bool activa) async {
    final index = _alarmas.indexWhere((a) => a.id == alarma.id);
    if (index!= -1) {
      _alarmas[index] = _alarmas[index].copyWith(activa: activa);
      notifyListeners();
      await _servicio.guardar(_alarmas[index]);
    }
  }

  Future<void> eliminarAlarma(String id) async {
    _alarmas.removeWhere((a) => a.id == id);
    notifyListeners();
    await _servicio.eliminar(id);
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _alarmas.removeAt(oldIndex);
    _alarmas.insert(newIndex, item);
    notifyListeners();
    await _servicio.actualizarOrden(_alarmas);
  }

  @override
  void dispose() {
    _ringSub?.cancel(); // <- IMPORTANTE: cierra la escucha al salir
    super.dispose();
  }
}