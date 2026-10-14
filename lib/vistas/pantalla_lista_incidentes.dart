import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modelos/incidente.dart';
import '../viewmodels/incidente_viewmodel.dart';

class PantallaListaIncidentes extends StatefulWidget {
  const PantallaListaIncidentes({super.key});

  @override
  State<PantallaListaIncidentes> createState() =>
      _PantallaListaIncidentesState();
}

class _PantallaListaIncidentesState extends State<PantallaListaIncidentes> {
  late final IncidenteViewModel viewModel;

  static const Color _verde = Color(0xFF0F766E);

  @override
  void initState() {
    super.initState();
    viewModel = IncidenteViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.cargarIncidentes();
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  /// Muestra todos los datos del incidente: foto, tipos, calle,
  /// descripción, fecha, ubicación GPS y estado.
  void _verDetalle(Incidente incidente) {
    final tieneFoto =
        incidente.foto.isNotEmpty && File(incidente.foto).existsSync();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          incidente.tipos.join(', '),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: tieneFoto
                      ? Image.file(File(incidente.foto), fit: BoxFit.contain)
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.no_photography,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Sin foto',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              _filaDetalle(Icons.location_on, 'Calle', incidente.calle),
              if (incidente.descripcion.isNotEmpty)
                _filaDetalle(
                    Icons.notes, 'Descripción', incidente.descripcion),
              _filaDetalle(
                  Icons.schedule, 'Fecha', _formatearFecha(incidente.fecha)),
              _filaDetalle(
                Icons.my_location,
                'Ubicación GPS',
                incidente.tieneUbicacion
                    ? '${incidente.latitud!.toStringAsFixed(5)}, '
                        '${incidente.longitud!.toStringAsFixed(5)}'
                    : 'No registrada',
              ),
              _filaDetalle(Icons.info_outline, 'Estado', 'En tratamiento'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _verde),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Una fila del detalle: ícono, título en negrita y valor.
  Widget _filaDetalle(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: _verde),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(valor, style: GoogleFonts.poppins(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Incidente incidente) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _DialogoEliminarIncidente(descripcion: incidente.tipos.join(', ')),
    );
    if (!mounted) return;
    if (confirmado == true) {
      await viewModel.eliminarIncidente(incidente.id);
    }
  }

  String _formatearFecha(String iso) {
    try {
      final fecha = DateTime.parse(iso);
      final d = fecha.day.toString().padLeft(2, '0');
      final m = fecha.month.toString().padLeft(2, '0');
      final a = fecha.year;
      final h = fecha.hour.toString().padLeft(2, '0');
      final min = fecha.minute.toString().padLeft(2, '0');
      return '$d/$m/$a $h:$min';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incidentes reportados',
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
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.cargando) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return Center(child: Text(viewModel.error!));
            }
            if (viewModel.estaVacio) {
              return Center(
                child: Text(
                  'Todavía no reportaste incidentes',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: viewModel.incidentes.length,
              itemBuilder: (context, index) {
                final incidente = viewModel.incidentes[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () => _verDetalle(incidente),
                    leading: const Icon(
                      Icons.warning_amber,
                      color: _verde,
                      size: 32,
                    ),
                    title: Text(
                      incidente.tipos.join(', '),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incidente.calle.isNotEmpty)
                          Text(
                            '📍 ${incidente.calle}',
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                        if (incidente.descripcion.isNotEmpty)
                          Text(
                            '📝 ${incidente.descripcion}',
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                        Row(
                          children: [
                            Text(
                              '🕐 ${_formatearFecha(incidente.fecha)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (incidente.foto.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.photo_camera,
                                  size: 14, color: Colors.grey),
                            ],
                            if (incidente.tieneUbicacion) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.my_location,
                                  size: 14, color: Colors.grey),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: _verde),
                      onSelected: (opcion) {
                        if (opcion == 'detalle') {
                          _verDetalle(incidente);
                        } else if (opcion == 'eliminar') {
                          _confirmarEliminar(incidente);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'detalle',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 8),
                              Text('Ver detalle'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Diálogo que espera 3 segundos antes de habilitar el botón de eliminar.
class _DialogoEliminarIncidente extends StatefulWidget {
  final String descripcion;
  const _DialogoEliminarIncidente({required this.descripcion});

  @override
  State<_DialogoEliminarIncidente> createState() =>
      _DialogoEliminarIncidenteState();
}

class _DialogoEliminarIncidenteState extends State<_DialogoEliminarIncidente> {
  int _segundos = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_segundos > 0) {
        setState(() => _segundos--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = _segundos == 0;
    return AlertDialog(
      title: const Text('Eliminar incidente'),
      content: Text(
        'Se eliminará el reporte "${widget.descripcion}".\n\n'
        '${ok ? '¿Confirmás?' : 'Podrás confirmar en $_segundos seg.'}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: ok ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(ok ? 'Eliminar' : 'Eliminar ($_segundos)'),
        ),
      ],
    );
  }
}