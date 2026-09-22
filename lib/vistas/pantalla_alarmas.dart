import 'package:flutter/material.dart';

import '../modelos/alarma.dart';
import '../viewmodels/alarma_viewmodel.dart';
import 'pantalla_formulario_alarma.dart';

class PantallaAlarmas extends StatefulWidget {
  const PantallaAlarmas({super.key});

  @override
  State<PantallaAlarmas> createState() => _PantallaAlarmasState();
}

class _PantallaAlarmasState extends State<PantallaAlarmas> {
  late final AlarmaViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AlarmaViewModel();
    viewModel.cargarAlarmas();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _abrirFormulario({Alarma? alarma}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormularioAlarma(
          viewModel: viewModel,
          alarmaEditar: alarma,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Alarmas')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.alarmas.isEmpty) {
            return const Center(child: Text('No hay alarmas configuradas.'));
          }

          return ReorderableListView.builder(
            itemCount: viewModel.alarmas.length,
            onReorder: viewModel.reordenar,
            itemBuilder: (context, index) {
              final alarma = viewModel.alarmas[index];

              return Dismissible(
                key: Key(alarma.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  viewModel.eliminarAlarma(alarma.id);
                },
                child: ListTile(
                  key: Key('tile_${alarma.id}'),
                  onTap: () => _abrirFormulario(alarma: alarma),
                  title: Text(
                    alarma.hora,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    alarma.dias.isEmpty ? 'Sin días' : 'Días: ${alarma.dias}',
                  ),
                  trailing: Switch(
                    value: alarma.activa,
                    onChanged: (valor) {
                      viewModel.alternarActivacion(alarma, valor);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}