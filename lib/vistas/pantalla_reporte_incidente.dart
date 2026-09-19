import 'package:flutter/material.dart';

import 'dart:async';

import '../viewmodels/incidente_viewmodel.dart';
import 'pantalla_lista_incidentes.dart';

class PantallaReporteIncidente extends StatefulWidget {
  const PantallaReporteIncidente({super.key});

  @override
  State<PantallaReporteIncidente> createState() =>
      _PantallaReporteIncidenteState();
}

class _PantallaReporteIncidenteState extends State<PantallaReporteIncidente> {
  late final IncidenteViewModel viewModel;
  final TextEditingController controladorDescripcion = TextEditingController();
  final TextEditingController controladorCalle = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = IncidenteViewModel();
  }

  @override
  void dispose() {
    controladorDescripcion.dispose();
    controladorCalle.dispose();
    viewModel.dispose();
    super.dispose();
  }

  /// Abre el diálogo de confirmación. Si el usuario confirma, guarda el incidente.
  Future<void> _confirmarGuardado() async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DialogoConfirmacion(),
    );
    if (confirmado != true) return;

    final ok = await viewModel.guardarIncidente(
      descripcion: controladorDescripcion.text,
      calle: controladorCalle.text,
    );

    if (!mounted) return;

    if (ok) {
      viewModel.limpiarFormulario();
      controladorDescripcion.clear();
      controladorCalle.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidente guardado correctamente')),
      );
      Navigator.pop(context);
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(viewModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50),
                    SizedBox(height: 8),
                    Text('Adjuntar foto'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaListaIncidentes(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Ver reportes'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controladorCalle,
              decoration: const InputDecoration(
                labelText: 'Calle o intersección',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, child) {
                  return ListView(
                    children: [
                      ...viewModel.tiposDisponibles.map(
                        (tipo) => CheckboxListTile(
                          title: Text(tipo),
                          value: viewModel.estaSeleccionado(tipo),
                          onChanged: (seleccionado) {
                            viewModel.alternarTipo(tipo, seleccionado ?? false);
                          },
                        ),
                      ),
                      if (viewModel.mostrarCampoOtros)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controladorDescripcion,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            maxLength: 200,
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmarGuardado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
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

/// Diálogo de confirmación con cuenta regresiva.
class _DialogoConfirmacion extends StatefulWidget {
  const _DialogoConfirmacion();

  @override
  State<_DialogoConfirmacion> createState() => _DialogoConfirmacionState();
}

class _DialogoConfirmacionState extends State<_DialogoConfirmacion> {
  int _cuentaInicial = 3;
  bool _puedeConfirmar = false;
  int _segundosRestantes = 15;
  Timer? _timerInicial;
  Timer? _timerCuentaRegresiva;

  @override
  void initState() {
    super.initState();
    _timerInicial = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cuentaInicial--;
        if (_cuentaInicial <= 0) {
          t.cancel();
          _puedeConfirmar = true;
          _iniciarCuentaRegresiva();
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
          Navigator.pop(context, false);
        }
      });
    });
  }

  @override
  void dispose() {
    _timerInicial?.cancel();
    _timerCuentaRegresiva?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar envío'),
      content: Text(
        _puedeConfirmar
            ? '¿Desea enviar?\nSe cancelará en $_segundosRestantes s'
            : 'Esperá... $_cuentaInicial',
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFC62828)),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _puedeConfirmar
              ? () => Navigator.pop(context, true)
              : null,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
