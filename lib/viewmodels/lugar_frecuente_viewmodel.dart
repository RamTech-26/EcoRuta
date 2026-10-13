import 'package:flutter/foundation.dart';
import '../modelos/lugar_frecuente.dart';
import '../servicios/lugar_frecuente_servicio.dart';

class LugarFrecuenteViewModel extends ChangeNotifier {
  final LugarFrecuenteServicio _servicio = LugarFrecuenteServicio();
  List<LugarFrecuente> _lugares = [];
  bool _cargando = false;
  String? _error;

  List<LugarFrecuente> get lugares => _lugares;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacio => _lugares.isEmpty &&!_cargando && _error == null;

  Future<void> cargarLugares() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _lugares = await _servicio.obtenerTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregarLugar(LugarFrecuente lugar) async {
    await _servicio.guardar(lugar);
    await cargarLugares();
  }

  Future<void> eliminarLugar(String id) async {
    final respaldo = List<LugarFrecuente>.from(_lugares);
    _lugares.removeWhere((l) => l.id == id);
    notifyListeners();
    try {
      await _servicio.eliminar(id);
    } catch (e) {
      _lugares = respaldo;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _lugares.removeAt(oldIndex);
    _lugares.insert(newIndex, item);
    notifyListeners();
    try {
      await _servicio.actualizarOrden(_lugares);
    } catch (e) {
      _error = e.toString();
      await cargarLugares();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}