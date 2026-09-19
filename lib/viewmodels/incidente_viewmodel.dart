import 'package:flutter/foundation.dart';

import '../modelos/incidente.dart';
import '../servicios/incidente_servicio.dart';

/// ViewModel de incidentes.
/// Guarda los tipos marcados en el formulario y maneja
/// el guardado y la lista de incidentes reportados.
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

  // Tipos marcados en el formulario
  final List<String> _seleccionados = [];
  List<String> get seleccionados => _seleccionados;

  /// ¿Está marcado este tipo?
  bool estaSeleccionado(String tipo) => _seleccionados.contains(tipo);

  /// Marca o desmarca un tipo.
  void alternarTipo(String tipo, bool marcado) {
    if (marcado) {
      _seleccionados.add(tipo);
    } else {
      _seleccionados.remove(tipo);
    }
    notifyListeners();
  }

  /// ¿Hay que mostrar el campo "Otros"?
  bool get mostrarCampoOtros => _seleccionados.contains('Otros');

  // Estado de la lista de incidentes
  List<Incidente> _incidentes = [];
  bool _cargando = false;
  String? _error;

  List<Incidente> get incidentes => _incidentes;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacio => _incidentes.isEmpty && !_cargando && _error == null;

  /// Carga todos los incidentes desde la base.
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

  /// Guarda un incidente nuevo con los datos del formulario.
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

  /// Elimina un incidente por su id.
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

  /// Limpia el formulario después de guardar.
  void limpiarFormulario() {
    _seleccionados.clear();
    _error = null;
    notifyListeners();
  }
}