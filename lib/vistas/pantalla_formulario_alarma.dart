import 'package:flutter/material.dart';
import '../modelos/alarma.dart';
import '../modelos/lugar_frecuente.dart';
import '../viewmodels/alarma_viewmodel.dart';
import '../servicios/lugar_frecuente_servicio.dart';

// Usamos StatefulWidget porque la pantalla necesita recordar datos que cambian (hora y lugar seleccionados)[cite: 6].
class PantallaFormularioAlarma extends StatefulWidget {
  final AlarmaViewModel viewModel;

  const PantallaFormularioAlarma({super.key, required this.viewModel});

  @override
  State<PantallaFormularioAlarma> createState() => _PantallaFormularioAlarmaState();
}

class _PantallaFormularioAlarmaState extends State<PantallaFormularioAlarma> {
  final LugarFrecuenteServicio _lugarServicio = LugarFrecuenteServicio();
  List<LugarFrecuente> _lugares = [];
  String? _lugarIdSeleccionado;
  TimeOfDay? _horaSeleccionada;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarLugares(); // Carga inicial de lugares frecuentes[cite: 15].
  }

  Future<void> _cargarLugares() async {
    final lugares = await _lugarServicio.obtenerTodos();
    // if (!mounted) return; evita errores si el widget se destruyó esperando la respuesta de la BD[cite: 15, 18].
    if (!mounted) return;
    setState(() {
      _lugares = lugares;
      _cargando = false;
    });
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null && mounted) {
      // setState avisa a Flutter que redibuje la pantalla con la nueva hora[cite: 6].
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  void _guardar() {
    if (_lugarIdSeleccionado == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos')),
      );
      return;
    }

    // Formateo simple de hora HH:mm
    final horaStr = _horaSeleccionada!.hour.toString().padLeft(2, '0');
    final minutoStr = _horaSeleccionada!.minute.toString().padLeft(2, '0');

    final nuevaAlarma = Alarma(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lugarId: _lugarIdSeleccionado!,
      hora: '$horaStr:$minutoStr',
      activa: true,
    );

    // Guarda en SQLite usando el ViewModel
    widget.viewModel.agregarAlarma(nuevaAlarma);
    
    // Navigator.pop cierra la pantalla actual y vuelve a la anterior[cite: 9].
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provee la estructura visual básica (AppBar, body)[cite: 8].
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Alarma')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              // Column acomoda los widgets uno debajo del otro[cite: 4, 6].
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Lugar Frecuente',
                      border: OutlineInputBorder(),
                    ),
                    value: _lugarIdSeleccionado,
                    items: _lugares.map((lugar) {
                      return DropdownMenuItem(
                        value: lugar.id,
                        child: Text(lugar.nombre),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _lugarIdSeleccionado = valor;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Text(
                      _horaSeleccionada == null
                          ? 'Seleccionar Hora'
                          : 'Hora: ${_horaSeleccionada!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _seleccionarHora,
                  ),
                  const Spacer(),
                  // ElevatedButton dispara la acción de guardado[cite: 5, 6].
                  ElevatedButton(
                    onPressed: _guardar,
                    child: const Text('Guardar Alarma'),
                  ),
                ],
              ),
            ),
    );
  }
}