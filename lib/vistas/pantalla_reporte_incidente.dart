import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        title: Text(
          'Reportar Incidente',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white, // <-- FONDO BLANCO
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área de foto
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // <-- gris claro para que se vea el área
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Color(0xFF0F766E)),
                      SizedBox(height: 8),
                      Text(
                        'Adjuntar foto',
                        style: TextStyle(color: Color(0xFF0F766E)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón ver reportes
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
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F766E),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campo calle
              TextField(
                controller: controladorCalle,
                decoration: InputDecoration(
                  hintText: 'Calle o intersección',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0F766E)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Lista de tipos de incidente
              Expanded(
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, child) {
                    return ListView(
                      children: [
                        ...viewModel.tiposDisponibles.map(
                          (tipo) => CheckboxListTile(
                            title: Text(
                              tipo,
                              style: GoogleFonts.poppins(color: Colors.black87),
                            ),
                            value: viewModel.estaSeleccionado(tipo),
                            activeColor: const Color(0xFF0F766E),
                            checkColor: Colors.white,
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
                              decoration: InputDecoration(
                                hintText: 'Describí el incidente...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Volver'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmarGuardado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F766E)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}