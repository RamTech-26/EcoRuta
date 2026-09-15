import 'package:flutter/material.dart';

import 'dart:async';
import '../viewmodels/reporte_incidente_viewmodel.dart';

class PantallaReporteIncidente extends StatefulWidget {
  const PantallaReporteIncidente({super.key});

  @override
  State<PantallaReporteIncidente> createState() =>
      _PantallaReporteIncidenteState();
}

class _PantallaReporteIncidenteState extends State<PantallaReporteIncidente> {
  late final ReporteIncidenteViewModel viewModel; // se guarda el ViewModel

  @override
  void initState() {
    super.initState();                              // siempre primero
    viewModel = ReporteIncidenteViewModel();        // se crea una sola vez
  }

  @override
  void dispose() {
    viewModel.dispose();                            // libera recursos
    super.dispose();                                // siempre al final
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Incidente'),    // título de la barra
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,                          // altura del cuadrado
              decoration: BoxDecoration(
                color: Colors.grey[300],            // gris claro de fondo
                borderRadius: BorderRadius.circular(12), // esquinas redondeadas
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50), // ícono de cámara
                    SizedBox(height: 8),
                    Text('Adjuntar foto'),             // texto indicativo
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListenableBuilder(               // escucha al ViewModel
                listenable: viewModel,
                builder: (context, child) {
                  return ListView(                    // lista desplazable
                    children: [
                      ...viewModel.tiposDisponibles.map( // recorre los tipos
                        (tipo) => CheckboxListTile(      // un checkbox por tipo
                          title: Text(tipo),
                          value: viewModel.estaSeleccionado(tipo),
                          onChanged: (seleccionado) {
                            viewModel.alternarIncidente(
                              tipo,
                              seleccionado ?? false,
                            );
                          },
                        ),
                      ),
                      if (viewModel.mostrarCampoOtros)   // solo si "Otros" está marcado
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: viewModel.controladorDescripcion,
                            maxLines: 4,                 // permite varias líneas
                            keyboardType: TextInputType.multiline,
                            maxLength: 200,              // máximo 200 caracteres
                            decoration: const InputDecoration(
                              hintText: 'Describí el incidente...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);            // vuelve atrás
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828), // rojo ladrillo
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(                        // abre diálogo
                        context: context,
                        barrierDismissible: false,       // no se cierra tocando afuera
                        builder: (context) => const _DialogoConfirmacion(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32), // verde bosque
                      foregroundColor: Colors.white,
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
  int _cuentaInicial = 3;                 // cuenta 3, 2, 1
  bool _puedeConfirmar = false;           // controla si OK está activo
  int _segundosRestantes = 15;            // cuenta regresiva final
  Timer? _timerInicial;                   // controla 3.. 2.. 1..
  Timer? _timerCuentaRegresiva;           // controla los 15s

  @override
  void initState() {
    super.initState();
    _timerInicial = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cuentaInicial--;
        if (_cuentaInicial <= 0) {
          t.cancel();
          _puedeConfirmar = true;         // muestra OK
          _iniciarCuentaRegresiva();      // arranca los 15s
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
          Navigator.pop(context);         // cierra solo
        }
      });
    });
  }

  @override
  void dispose() {
    _timerInicial?.cancel();              // libera el timer
    _timerCuentaRegresiva?.cancel();      // libera el timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar envío'),
      content: Text(
        _puedeConfirmar
            ? '¿Desea enviar?\nSe cancelará en $_segundosRestantes s' // fase 2
            : 'Esperá... $_cuentaInicial',                              // fase 1
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFC62828), // texto rojo
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _puedeConfirmar
              ? () {
                  Navigator.pop(context);       // cierra diálogo
                  Navigator.pop(context);       // cierra pantalla
                }
              : null,                            // deshabilitado durante 3.. 2.. 1..
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32), // texto verde
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}