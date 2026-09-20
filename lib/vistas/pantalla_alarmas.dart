import 'package:flutter/material.dart';

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

          // Permite reordenar con onLongPress y mantiene posiciones fijas
          return ReorderableListView.builder(
            itemCount: viewModel.alarmas.length,
            onReorder: viewModel.reordenar,
            itemBuilder: (context, index) {
              final alarma = viewModel.alarmas[index];

              return Dismissible(
                key: Key(alarma.id), // Key única por elemento[cite: 8, 24]
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
                child: SwitchListTile(
                  title: Text(
                    alarma.hora,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Días: ${alarma.dias}',
                  ), // Muestra los días en el subtítulo
                  value: alarma.activa,
                  onChanged: (valor) {
                    viewModel.alternarActivacion(alarma, valor);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaFormularioAlarma(viewModel: viewModel),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
