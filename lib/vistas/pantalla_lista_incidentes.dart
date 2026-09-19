import 'package:flutter/material.dart';

import '../modelos/incidente.dart';
import '../viewmodels/incidente_viewmodel.dart';

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
  Future<void> _confirmarEliminar(Incidente incidente) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar incidente'),
        content: Text(
          '¿Querés eliminar el reporte de "${incidente.tipos.join(', ')}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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
            return const Center(child: Text('Todavía no reportaste incidentes'));
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarEliminar(incidente),
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