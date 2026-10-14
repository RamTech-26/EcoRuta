import 'package:flutter/material.dart';

import '../modelos/lugar_frecuente.dart';
import '../servicios/lugar_frecuente_servicio.dart';

/// ViewModel de la pantalla principal.
/// Maneja los campos de origen y destino, los lugares frecuentes
/// para elegir como destino, y el panel deslizable inferior.
class PrincipalViewModel extends ChangeNotifier {
  final TextEditingController controladorBusqueda = TextEditingController();
  final TextEditingController controladorDestino = TextEditingController();

  final DraggableScrollableController controladorPanel =
      DraggableScrollableController();

  final LugarFrecuenteServicio _lugarServicio = LugarFrecuenteServicio();

  PrincipalViewModel() {
    controladorDestino.addListener(_alCambiarDestino);
  }

  // ---------- Lugares frecuentes como destino ----------

  List<LugarFrecuente> _lugares = [];
  LugarFrecuente? _destinoSeleccionado;

  List<LugarFrecuente> get lugares => _lugares;

  /// Lugar elegido con un chip. Guarda las coordenadas para la ruta
  /// sugerida (sprint 3). Es null si el destino se escribió a mano.
  LugarFrecuente? get destinoSeleccionado => _destinoSeleccionado;

  Future<void> cargarLugares() async {
    try {
      _lugares = await _lugarServicio.obtenerTodos();
    } catch (_) {
      _lugares = [];
    }
    // Si el lugar elegido se borró o se editó, actualizamos la selección.
    if (_destinoSeleccionado != null) {
      final id = _destinoSeleccionado!.id;
      final actualizado = _lugares.where((l) => l.id == id).toList();
      _destinoSeleccionado = actualizado.isEmpty ? null : actualizado.first;
    }
    notifyListeners();
  }

  void seleccionarLugar(LugarFrecuente lugar) {
    _destinoSeleccionado = lugar;
    controladorDestino.text = lugar.direccion;
    notifyListeners();
  }

  /// Si el usuario cambia el texto a mano, deja de ser un lugar frecuente.
  void _alCambiarDestino() {
    final seleccionado = _destinoSeleccionado;
    if (seleccionado != null &&
        controladorDestino.text != seleccionado.direccion) {
      _destinoSeleccionado = null;
      notifyListeners();
    }
  }

  // ---------- Panel deslizable ----------

  /// Abre o cierra el panel deslizable según su posición actual.
  void alternarPanel() {
    final abierto = controladorPanel.size > 0.2;
    controladorPanel.animateTo(
      abierto ? 0.1 : 0.6,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void cerrarPanel() {
    controladorPanel.animateTo(
      0.1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    controladorDestino.removeListener(_alCambiarDestino);
    controladorBusqueda.dispose();
    controladorDestino.dispose();
    controladorPanel.dispose();
    super.dispose();
  }
}