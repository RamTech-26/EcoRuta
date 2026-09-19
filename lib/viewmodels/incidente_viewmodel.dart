import 'package:flutter/foundation.dart';

import '../modelos/incidente.dart';
import '../servicios/incidente_servicio.dart';

/// ViewModel de incidentes.
/// Maneja el formulario de reporte y la lista de incidentes guardados.
class IncidenteViewModel extends ChangeNotifier {
  final IncidenteServicio _servicio = IncidenteServicio();

  // Tipos disponibles en el formulario
  final List<String> tiposDisponibles = const [
    'Choque',
    'Semáforo roto',
    'Accidente',
    'Ruta rota',
    'Inundación',
    'Otros',
  ];

  // Tipos marcados
  final List<String> _seleccionados = [];
  List<String> get seleccionados => _seleccionados;

  bool estaSeleccionado(String tipo) => _seleccionados.contains(tipo);

  void alternarTipo(String tipo, bool marcado) {
    if (marcado) {
      _seleccionados.add(tipo);
    } else {
      _seleccionados.remove(tipo);
    }
    notifyListeners();
  }

  bool get mostrarCampoOtros => _seleccionados.contains('Otros');

  // Estado de la lista de incidentes
  List<Incidente> _incidentes = [];
  bool _cargando = false;
  String? _error;

  List<Incidente> get incidentes => _incidentes;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacio => _incidentes.isEmpty && !_cargando && _error == null;

  Future<void> cargarIncidentes() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _incidentes = await _servicio.obtenerTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Guarda un incidente nuevo. Devuelve true si salió bien.
  Future<bool> guardarIncidente({
    required String descripcion,
    required String calle,
  }) async {
    if (_seleccionados.isEmpty) {
      _error = 'Marcá al menos un tipo de incidente';
      notifyListeners();
      return false;
    }
    if (calle.trim().isEmpty) {
      _error = 'Completá la calle o intersección';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final incidente = Incidente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipos: List<String>.from(_seleccionados),
        descripcion: descripcion.trim(),
        calle: calle.trim(),
        fecha: DateTime.now().toIso8601String(),
        foto: '',
      );
      await _servicio.guardar(incidente);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> eliminarIncidente(String id) async {
    final respaldo = List<Incidente>.from(_incidentes);
    _incidentes.removeWhere((i) => i.id == id);
    notifyListeners();
    try {
      await _servicio.eliminar(id);
    } catch (e) {
      _incidentes = respaldo;
      _error = e.toString();
      notifyListeners();
    }
  }

  void limpiarFormulario() {
    _seleccionados.clear();
    _error = null;
    notifyListeners();
  }
}