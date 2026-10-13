
import 'package:flutter/widgets.dart';

class ReporteIncidenteViewModel extends ChangeNotifier {
  final List<String> _incidentesSeleccionados = [];
  List<String> get incidentesSeleccionados => List.unmodifiable(_incidentesSeleccionados);

  final TextEditingController controladorDescripcion = TextEditingController();

  final List<String> tiposDisponibles = const [
    'Choque',
    'Semáforo roto',
    'Accidente',
    'Ruta rota',
    'Inundación',
    'Otros',
  ];

  bool estaSeleccionado(String tipo) {
    return _incidentesSeleccionados.contains(tipo);
  }

  void alternarIncidente(String tipo, bool seleccionado) {
    if (seleccionado) {
      if (!_incidentesSeleccionados.contains(tipo)) {
        _incidentesSeleccionados.add(tipo); // evita duplicados
      }
    } else {
      _incidentesSeleccionados.remove(tipo);
    }
    notifyListeners(); // siempre después de modificar
  }

  bool get mostrarCampoOtros => _incidentesSeleccionados.contains('Otros');

  void limpiar() {
    _incidentesSeleccionados.clear();
    controladorDescripcion.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    controladorDescripcion.dispose();
    super.dispose();
  }
}