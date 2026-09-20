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
  State<PantallaFormularioAlarma> createState() =>
      _PantallaFormularioAlarmaState();
}

class _PantallaFormularioAlarmaState extends State<PantallaFormularioAlarma> {
  final LugarFrecuenteServicio _lugarServicio = LugarFrecuenteServicio();
  // Días disponibles para la selección
  final List<String> _diasSemana = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];
  final List<String> _diasSeleccionados = [];

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
    if (_lugarIdSeleccionado == null ||
        _horaSeleccionada == null ||
        _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá todos los campos y elegí al menos un día'),
        ),
      );
      return;
    }

    final horaStr = _horaSeleccionada!.hour.toString().padLeft(2, '0');
    final minutoStr = _horaSeleccionada!.minute.toString().padLeft(2, '0');

    final nuevaAlarma = Alarma(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lugarId: _lugarIdSeleccionado!,
      hora: '$horaStr:$minutoStr',
      dias: _diasSeleccionados.join(', '), // Une los días seleccionados
      activa: true,
      orden: widget.viewModel.alarmas.length,
    );

    widget.viewModel.agregarAlarma(nuevaAlarma);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Alarma')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Permite scroll en pantallas pequeñas o al abrir el teclado
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Selector de Lugar Frecuente
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

                  // 2. Selector de Hora
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
                  const SizedBox(height: 16),

                  // 3. Selector de Días con FilterChip
                  const Text(
                    'Días de activación:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    children: _diasSemana.map((dia) {
                      final seleccionado = _diasSeleccionados.contains(dia);
                      return FilterChip(
                        label: Text(dia),
                        selected: seleccionado,
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        onSelected: (bool val) {
                          setState(() {
                            if (val) {
                              _diasSeleccionados.add(dia);
                            } else {
                              _diasSeleccionados.remove(dia);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32), // Reemplaza al Spacer() erróneo
                  // 4. Botón Guardar
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
