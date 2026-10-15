import 'dart:async';

import 'package:flutter/foundation.dart';

import '../modelos/alarma.dart';
import '../repositorios/alarma_repositorio.dart';
import '../servicios/alarma_servicio.dart';

class AlarmaViewModel extends ChangeNotifier {
  final AlarmaRepositorio _alarmaRepositorio;
  final AlarmaServicio _alarmaServicio;
  List<Alarma> _alarmas = [];
  bool _cargando = false;
  String? _error;
  StreamSubscription? _ringSub;

  List<Alarma> get alarmas => _alarmas;
  bool get cargando => _cargando;
  String? get error => _error;

  AlarmaViewModel({
    required this._alarmaRepositorio,
    required this._alarmaServicio,
  }) {
    _escucharEventosDeAlarma();
  }

  Future<void> cargarAlarmas() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _alarmas = await _alarmaRepositorio.obtenerTodas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void _escucharEventosDeAlarma() {
    _ringSub?.cancel();
    _ringSub = AlarmaServicio.onRing.listen((alarmSettings) async {
      final alarmasGuardadas = await _alarmaRepositorio.obtenerTodas();
      for (var a in alarmasGuardadas) {
        if (a.activa) {
          await _alarmaServicio.programarAlarmaNativa(a);
        }
      }
      _alarmas = alarmasGuardadas;
      notifyListeners();
    });
  }

  Future<void> guardarAlarma(Alarma alarma) async {
    await _alarmaRepositorio.guardar(alarma);
    if (alarma.activa) {
      await _alarmaServicio.programarAlarmaNativa(alarma);
    } else {
      await _alarmaServicio.cancelarAlarmaNativa(alarma.id);
    }
    await cargarAlarmas();
  }

  Future<void> alternarActivacion(Alarma alarma, bool activa) async {
    final index = _alarmas.indexWhere((a) => a.id == alarma.id);
    if (index != -1) {
      _alarmas[index] = _alarmas[index].copyWith(activa: activa);
      notifyListeners();
      await _alarmaRepositorio.guardar(_alarmas[index]);
      if (activa) {
        await _alarmaServicio.programarAlarmaNativa(_alarmas[index]);
      } else {
        await _alarmaServicio.cancelarAlarmaNativa(_alarmas[index].id);
      }
    }
  }

  Future<void> eliminarAlarma(String id) async {
    _alarmas.removeWhere((a) => a.id == id);
    notifyListeners();
    await _alarmaRepositorio.eliminar(id);
    await _alarmaServicio.cancelarAlarmaNativa(id);
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _alarmas.removeAt(oldIndex);
    _alarmas.insert(newIndex, item);
    notifyListeners();
    await _alarmaRepositorio.actualizarOrden(_alarmas);
  }

  @override
  void dispose() {
    _ringSub?.cancel();
    super.dispose();
  }
}
