import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const Color _verde = Color(0xFF0F766E);

  @override
  void initState() {
    super.initState();
    viewModel = IncidenteViewModel();
    // Toma la ubicación apenas se abre la pantalla
    viewModel.obtenerUbicacion();
  }

  @override
  void dispose() {
    controladorDescripcion.dispose();
    controladorCalle.dispose();
    viewModel.dispose();
    super.dispose();
  }

  /// Muestra un menú para elegir entre cámara y galería.
  Future<void> _elegirOrigenFoto() async {
    final desdeGaleria = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: _verde),
              title: const Text('Sacar foto'),
              onTap: () => Navigator.pop(context, false),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _verde),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (desdeGaleria == null) return; // cerró el menú sin elegir
    await viewModel.tomarFoto(desdeGaleria: desdeGaleria);
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

  /// Recuadro de la foto: muestra la foto tomada o el botón para adjuntar.
  Widget _areaFoto() {
    if (viewModel.tieneFoto) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: Image.file(File(viewModel.rutaFoto!), fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Quitar foto',
                onPressed: viewModel.quitarFoto,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _elegirOrigenFoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 50, color: _verde),
              SizedBox(height: 8),
              Text('Adjuntar foto', style: TextStyle(color: _verde)),
            ],
          ),
        ),
      ),
    );
  }

  /// Línea que indica el estado de la ubicación GPS.
  Widget _estadoUbicacion() {
    if (viewModel.obteniendoUbicacion) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _verde),
          ),
          SizedBox(width: 8),
          Text('Obteniendo ubicación...'),
        ],
      );
    }

    if (viewModel.tieneUbicacion) {
      return Row(
        children: [
          const Icon(Icons.my_location, size: 18, color: _verde),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ubicación registrada '
              '(${viewModel.latitud!.toStringAsFixed(5)}, '
              '${viewModel.longitud!.toStringAsFixed(5)})',
              style: const TextStyle(color: _verde),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.location_off, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            viewModel.avisoUbicacion ?? 'Sin ubicación',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: viewModel.obtenerUbicacion,
          style: TextButton.styleFrom(foregroundColor: _verde),
          child: const Text('Reintentar'),
        ),
      ],
    );
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
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Todo el formulario se puede scrollear
                  Expanded(
                    child: ListView(
                      children: [
                        // Área de foto
                        _areaFoto(),
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
                            foregroundColor: _verde,
                            side: const BorderSide(color: _verde),
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
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: _verde,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _verde,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Estado de la ubicación GPS
                        _estadoUbicacion(),
                        const SizedBox(height: 8),

                        // Tipos de incidente
                        ...viewModel.tiposDisponibles.map(
                          (tipo) => CheckboxListTile(
                            title: Text(
                              tipo,
                              style: GoogleFonts.poppins(color: Colors.black87),
                            ),
                            value: viewModel.estaSeleccionado(tipo),
                            activeColor: _verde,
                            checkColor: Colors.white,
                            onChanged: (seleccionado) {
                              viewModel.alternarTipo(
                                tipo,
                                seleccionado ?? false,
                              );
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _verde,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botones (quedan fijos abajo)
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
                          onPressed: viewModel.cargando
                              ? null
                              : _confirmarGuardado,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verde,
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
              );
            },
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
