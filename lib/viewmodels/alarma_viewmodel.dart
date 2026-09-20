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

  // Modifica el estado 'activa' manteniendo la posición fija sin recargar la lista
  Future<void> alternarActivacion(Alarma alarma, bool activa) async {
    final index = _alarmas.indexWhere((a) => a.id == alarma.id);
    if (index != -1) {
      _alarmas[index] = _alarmas[index].copyWith(activa: activa);
      notifyListeners(); // Redibujado local en pantalla sin alterar la posición
      await _servicio.guardar(_alarmas[index]);
    }
  }

  Future<void> eliminarAlarma(String id) async {
    _alarmas.removeWhere((a) => a.id == id);
    notifyListeners();
    await _servicio.eliminar(id);
  }

  // Mueve los ítems al mantener presionado (onLongPress)
  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _alarmas.removeAt(oldIndex);
    _alarmas.insert(newIndex, item);
    notifyListeners();
    try {
      await _servicio.actualizarOrden(_alarmas);
    } catch (e) {
      _error = e.toString();
      await cargarAlarmas();
    }
  }
}