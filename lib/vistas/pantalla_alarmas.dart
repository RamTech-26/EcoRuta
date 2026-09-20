import 'package:flutter/material.dart';
import '../viewmodels/alarma_viewmodel.dart';
import 'pantalla_formulario_alarma.dart'; // La crearemos en el próximo paso

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
    // Inicializa el ViewModel y carga las alarmas guardadas en SQLite[cite: 16]
    viewModel = AlarmaViewModel();
    viewModel.cargarAlarmas();
  }

  @override
  void dispose() {
    // Libera el listener del ViewModel para evitar fugas de memoria[cite: 13, 16]
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Alarmas')),
      // ListenableBuilder redibuja esta porción cuando notifyListeners() es llamado[cite: 13]
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.alarmas.isEmpty) {
            return const Center(child: Text('No hay alarmas configuradas.'));
          }

          // Renderiza la lista dinámica de alarmas[cite: 15]
          return ListView.builder(
            itemCount: viewModel.alarmas.length,
            itemBuilder: (context, index) {
              final alarma = viewModel.alarmas[index];
              
              // Dismissible permite eliminar el ítem deslizando hacia la izquierda[cite: 5, 12]
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
                  // Borra físicamente la alarma de la base de datos[cite: 12]
                  viewModel.eliminarAlarma(alarma.id);
                },
                child: SwitchListTile(
                  title: Text(
                    alarma.hora, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Alarma activa'),
                  value: alarma.activa,
                  onChanged: (valor) {
                    // Alterna el switch visual y actualiza en BD local
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
          // Navega al formulario apilando la pantalla nueva[cite: 3, 8]
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