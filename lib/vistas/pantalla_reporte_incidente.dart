import 'package:flutter/material.dart';

import 'dart:async';

class PantallaReporteIncidente extends StatefulWidget {
  // necesita estado para la selección
  const PantallaReporteIncidente({super.key});

  @override
  State<PantallaReporteIncidente> createState() =>
      _PantallaReporteIncidenteState();
}

class _PantallaReporteIncidenteState extends State<PantallaReporteIncidente> {
  final List<String> _incidentesSeleccionados = [];
  final TextEditingController _controladorDescripcion =
      TextEditingController(); // guarda el texto de "Otros"

  @override
  void dispose() {
    _controladorDescripcion.dispose(); // libera recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Incidente'), // título de la barra
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180, // altura del cuadrado
              decoration: BoxDecoration(
                color: Colors.grey[300], // gris claro de fondo
                borderRadius: BorderRadius.circular(12), // esquinas redondeadas
              ),
              child: Center(
                // centra el contenido
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50), // ícono de cámara
                    SizedBox(height: 8),
                    Text('Adjuntar foto'), // texto indicativo
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              // ocupa el espacio restante
              child: ListView(
                // lista desplazable
                children: [
                  CheckboxListTile(
                    // incidente 1
                    title: const Text('Choque'),
                    value: _incidentesSeleccionados.contains('Choque'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Choque');
                        } else {
                          _incidentesSeleccionados.remove('Choque');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 2
                    title: const Text('Semáforo roto'),
                    value: _incidentesSeleccionados.contains('Semáforo roto'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Semáforo roto');
                        } else {
                          _incidentesSeleccionados.remove('Semáforo roto');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 3
                    title: const Text('Accidente'),
                    value: _incidentesSeleccionados.contains('Accidente'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Accidente');
                        } else {
                          _incidentesSeleccionados.remove('Accidente');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 4
                    title: const Text('Ruta rota'),
                    value: _incidentesSeleccionados.contains('Ruta rota'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Ruta rota');
                        } else {
                          _incidentesSeleccionados.remove('Ruta rota');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 5
                    title: const Text('Inundación'),
                    value: _incidentesSeleccionados.contains('Inundación'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Inundación');
                        } else {
                          _incidentesSeleccionados.remove('Inundación');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 6
                    title: const Text('Otros'),
                    value: _incidentesSeleccionados.contains('Otros'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Otros');
                        } else {
                          _incidentesSeleccionados.remove('Otros');
                        }
                      });
                    },
                  ),
                  if (_incidentesSeleccionados.contains('Otros'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controladorDescripcion,
                        maxLines: 4, // permite varias líneas
                        keyboardType: TextInputType
                            .multiline, // teclado para texto extenso
                        maxLength: 200, // máximo 200 caracteres
                        decoration: InputDecoration(
                          hintText: 'Describí el incidente...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16), // espacio antes del botón
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // vuelve atrás
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828), // rojo ladrillo
                      foregroundColor: Colors.white
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12), // espacio entre botones
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        // abre diálogo
                        context: context,
                        barrierDismissible:
                            false, // no se cierra tocando afuera
                        builder: (context) => const _DialogoConfirmacion(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white // verde bosque
                    ),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoConfirmacion extends StatefulWidget {
  const _DialogoConfirmacion();

  @override
  State<_DialogoConfirmacion> createState() => _DialogoConfirmacionState();
}

class _DialogoConfirmacionState extends State<_DialogoConfirmacion> {
  int _cuentaInicial = 3; // cuenta 3, 2, 1
  bool _puedeConfirmar = false; // controla si OK está visible
  int _segundosRestantes = 15; // cuenta regresiva final
  Timer? _timerInicial; // controla 3.. 2.. 1..
  Timer? _timerCuentaRegresiva; // controla los 15s

  @override
  void initState() {
    super.initState();
    _timerInicial = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cuentaInicial--;
        if (_cuentaInicial <= 0) {
          t.cancel();
          _puedeConfirmar = true; // muestra OK
          _iniciarCuentaRegresiva(); // arranca los 15s
        }
      });
    });
  }

  void _iniciarCuentaRegresiva() {
    _timerCuentaRegresiva = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _segundosRestantes--;
        if (_segundosRestantes <= 0) {
          t.cancel();
          Navigator.pop(context); // cierra solo
        }
      });
    });
  }

  @override
  void dispose() {
    _timerInicial?.cancel(); // libera el timer
    _timerCuentaRegresiva?.cancel(); // libera el timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar envío'),
      content: Text(
        _puedeConfirmar
            ? '¿Desea enviar?\nSe cancelará en $_segundosRestantes s' // fase 2
            : 'Esperá... $_cuentaInicial', // fase 1
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween, // Cancelar izq, OK der
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // cierra diálogo
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _puedeConfirmar
              ? () {
                  Navigator.pop(context); // cierra diálogo
                  Navigator.pop(context); // cierra pantalla
                }
              : null, // deshabilitado durante 3.. 2.. 1..
          child: const Text('OK'),
        ),
      ],
    );
  }
}
