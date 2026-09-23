import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        title: Text(
          'Mis Alarmas',
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
        color: Colors.white,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.alarmas.isEmpty) {
              return Center(
                child: Text(
                  'No hay alarmas configuradas.',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              );
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
                    color: const Color(0xFFC62828),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    viewModel.eliminarAlarma(alarma.id);
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      key: Key('tile_${alarma.id}'),
                      onTap: () => _abrirFormulario(alarma: alarma),
                      title: Text(
                        alarma.hora,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        alarma.dias.isEmpty ? 'Sin días' : 'Días: ${alarma.dias}',
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                      trailing: Switch(
                        value: alarma.activa,
                        activeColor: const Color(0xFF0F766E),
                        onChanged: (valor) {
                          viewModel.alternarActivacion(alarma, valor);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}