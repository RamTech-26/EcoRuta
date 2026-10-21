import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../modelos/lugar_frecuente.dart';
import '../repositorios/alarma_repositorio.dart';
import '../servicios/alarma_servicio.dart';
import '../servicios/lugar_frecuente_servicio.dart';

class LugarFrecuenteViewModel extends ChangeNotifier {
  final LugarFrecuenteServicio _lugarServicio;
  final AlarmaRepositorio _alarmaRepositorio;
  final AlarmaServicio _alarmaServicio;
  List<LugarFrecuente> _lugares = [];
  bool _cargando = false;
  String? _error;

  List<LugarFrecuente> get lugares => _lugares;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacio => _lugares.isEmpty && !_cargando && _error == null;

  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;
  String? _avisoUbicacion;

  double? get latitud => _latitud;
  double? get longitud => _longitud;
  bool get obteniendoUbicacion => _obteniendoUbicacion;
  String? get avisoUbicacion => _avisoUbicacion;

  bool get tieneUbicacion =>
      _latitud != null &&
      _longitud != null &&
      !(_latitud == 0 && _longitud == 0);

  LugarFrecuenteViewModel({
    required this._lugarServicio,
    required this._alarmaRepositorio,
    required this._alarmaServicio,
  });

  void cargarUbicacion(double latitud, double longitud) {
    _latitud = latitud;
    _longitud = longitud;
  }

  Future<void> obtenerUbicacion() async {
    _obteniendoUbicacion = true;
    _avisoUbicacion = null;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _avisoUbicacion = 'Activá la ubicación del celular';
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        _avisoUbicacion = 'Sin permiso de ubicación';
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
    } catch (_) {
      _avisoUbicacion = 'No se pudo obtener la ubicación';
    } finally {
      _obteniendoUbicacion = false;
      notifyListeners();
    }
  }

  Future<void> cargarLugares() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _lugares = await _lugarServicio.obtenerTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregarLugar(LugarFrecuente lugar) async {
    await _lugarServicio.guardar(lugar);
    await cargarLugares();
  }

  Future<int> contarAlarmas(String lugarId) async {
    try {
      final alarmas = await _alarmaRepositorio.obtenerPorLugar(lugarId);
      return alarmas.length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> eliminarLugar(String id) async {
    final respaldo = List<LugarFrecuente>.from(_lugares);
    _lugares.removeWhere((l) => l.id == id);
    notifyListeners();
    try {
      final alarmas = await _alarmaRepositorio.obtenerPorLugar(id);
      for (final alarma in alarmas) {
        await _alarmaServicio.cancelarAlarmaNativa(alarma.id);
      }
      await _lugarServicio.eliminar(id);
    } catch (e) {
      _lugares = respaldo;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mueve el elemento de [oldIndex] a [newIndex].
  ///
  /// [newIndex] ya viene corregido por `onReorderItem` de
  /// ReorderableListView: no hay que restarle 1 al mover hacia abajo.
  Future<void> reordenar(int oldIndex, int newIndex) async {
    final item = _lugares.removeAt(oldIndex);
    _lugares.insert(newIndex, item);
    notifyListeners();
    try {
      await _lugarServicio.actualizarOrden(_lugares);
    } catch (e) {
      _error = e.toString();
      await cargarLugares();
    }
  }
}
