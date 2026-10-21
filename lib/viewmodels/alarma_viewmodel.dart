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

  /// Cuando suena una alarma, vuelve a programar las activas para su
  /// próxima fecha.
  void _escucharEventosDeAlarma() {
    _ringSub?.cancel();
    // Escuchamos el broadcast del servicio, NO el stream directo del plugin.
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

  /// Si las alarmas pueden sonar, sin pedirle nada al usuario.
  Future<EstadoPermisoAlarma> revisarPermisos() =>
      _alarmaServicio.revisarPermisos();

  /// Pide los permisos que falten (la vista ya explicó para qué).
  Future<EstadoPermisoAlarma> pedirPermisos() =>
      _alarmaServicio.pedirPermisos();

  /// Abre los ajustes de la app.
  Future<bool> abrirAjustes() => _alarmaServicio.abrirAjustes();

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

  /// Mueve el elemento de [oldIndex] a [newIndex].
  ///
  /// [newIndex] ya viene corregido por `onReorderItem` de
  /// ReorderableListView: no hay que restarle 1 al mover hacia abajo.
  Future<void> reordenar(int oldIndex, int newIndex) async {
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
