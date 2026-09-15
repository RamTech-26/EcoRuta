import 'package:flutter/material.dart'; // necesita ChangeNotifier y TextEditingController

class ReporteIncidenteViewModel extends ChangeNotifier {
  final List<String> _incidentesSeleccionados = []; // guarda los tipos marcados
  List<String> get incidentesSeleccionados => _incidentesSeleccionados; // getter público

  final TextEditingController controladorDescripcion =
      TextEditingController(); // guarda el texto de "Otros"

  final List<String> tiposDisponibles = const [ // tipos de incidente
    'Choque',
    'Semáforo roto',
    'Accidente',
    'Ruta rota',
    'Inundación',
    'Otros',
  ];

  bool estaSeleccionado(String tipo) {           // ¿el tipo está marcado?
    return _incidentesSeleccionados.contains(tipo);
  }

  void alternarIncidente(String tipo, bool seleccionado) { // marca o desmarca
    if (seleccionado) {
      _incidentesSeleccionados.add(tipo);        // agrega el tipo
    } else {
      _incidentesSeleccionados.remove(tipo);     // quita el tipo
    }
    notifyListeners();                           // avisa a la Vista
  }

  bool get mostrarCampoOtros =>                  // ¿hay que mostrar el campo "Otros"?
      _incidentesSeleccionados.contains('Otros');

  @override
  void dispose() {                               // libera recursos
    controladorDescripcion.dispose();            // libera el controller
    super.dispose();                             // siempre al final
  }
}

/* Cambios clave (ReporteIncidente)
ViewModel con lista de incidentesSeleccionados, controladorDescripcion, tiposDisponibles y métodos estaSeleccionado() / alternarIncidente().

La Vista ya no maneja la lista de seleccionados ni la lógica de los checkboxes.

La Vista solo lee el ViewModel (con ListenableBuilder) y llama a sus métodos.

Los checkboxes se generan automáticamente recorriendo tiposDisponibles con .map(), en lugar de estar escritos uno por uno.

El diálogo temporizado sigue como widget privado en la Vista porque son timers de UI puramente visuales, no lógica de negocio compartida.

 */