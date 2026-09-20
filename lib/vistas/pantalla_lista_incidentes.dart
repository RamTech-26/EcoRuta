import 'package:flutter/material.dart';

import '../modelos/incidente.dart';
import '../viewmodels/incidente_viewmodel.dart';

import 'dart:async';

/// Pantalla que muestra todos los incidentes reportados por el usuario.
class PantallaListaIncidentes extends StatefulWidget {
  const PantallaListaIncidentes({super.key});

  @override
  State<PantallaListaIncidentes> createState() =>
      _PantallaListaIncidentesState();
}

class _PantallaListaIncidentesState extends State<PantallaListaIncidentes> {
  late final IncidenteViewModel viewModel;

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

  /// Pide confirmación y elimina el incidente si el usuario acepta.
  /// Muestra un diálogo con el estado actual del reporte.
  void _verEstado(Incidente incidente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado del reporte'),
        content: const Text('Reporte en Tratamiento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Pide confirmación con cuenta regresiva de 3 segundos antes de eliminar.
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

  /// Formatea la fecha ISO a algo legible: "12/10/2026 15:30".
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
      appBar: AppBar(title: const Text('Incidentes reportados')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          if (viewModel.estaVacio) {
            return const Center(
              child: Text('Todavía no reportaste incidentes'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.incidentes.length,
            itemBuilder: (context, index) {
              final incidente = viewModel.incidentes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 32,
                  ),
                  title: Text(incidente.tipos.join(', ')),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (incidente.calle.isNotEmpty)
                        Text('📍 ${incidente.calle}'),
                      if (incidente.descripcion.isNotEmpty)
                        Text('📝 ${incidente.descripcion}'),
                      Text(
                        '🕐 ${_formatearFecha(incidente.fecha)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (opcion) {
                      if (opcion == 'estado') {
                        _verEstado(incidente);
                      } else if (opcion == 'eliminar') {
                        _confirmarEliminar(incidente);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'estado',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('Ver estado'),
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
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(ok ? 'Eliminar' : 'Eliminar ($_segundos)'),
        ),
      ],
    );
  }
}
