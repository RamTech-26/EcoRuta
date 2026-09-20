import 'package:flutter/foundation.dart';
import '../modelos/alarma.dart';
import '../servicios/alarma_servicio.dart';

class AlarmaViewModel extends ChangeNotifier {
  final AlarmaServicio _servicio = AlarmaServicio();
  List<Alarma> _alarmas = [];
  bool _cargando = false;
  String? _error;

  List<Alarma> get alarmas => _alarmas;
  bool get cargando => _cargando;
  String? get error => _error;

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

  Future<void> agregarAlarma(Alarma alarma) async {
    await _servicio.guardar(alarma);
    await cargarAlarmas();
  }

  Future<void> alternarActivacion(Alarma alarma, bool activa) async {
    final alarmaActualizada = alarma.copyWith(activa: activa);
    await _servicio.guardar(alarmaActualizada);
    await cargarAlarmas();
  }

  Future<void> eliminarAlarma(String id) async {
    await _servicio.eliminar(id);
    await cargarAlarmas();
  }
}