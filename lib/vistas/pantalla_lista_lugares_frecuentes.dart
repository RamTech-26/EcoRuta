import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';

import '../viewmodels/lugar_frecuente_viewmodel.dart';
import '../modelos/lugar_frecuente.dart';
import 'pantalla_formulario_lugar_frecuente.dart';

class PantallaListaLugaresFrecuentes extends StatefulWidget {
  const PantallaListaLugaresFrecuentes({super.key});
  @override
  State<PantallaListaLugaresFrecuentes> createState() =>
      _PantallaListaLugaresFrecuentesState();
}

class _PantallaListaLugaresFrecuentesState
    extends State<PantallaListaLugaresFrecuentes> {
  late final LugarFrecuenteViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = LugarFrecuenteViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.cargarLugares();
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmarEliminar(LugarFrecuente lugar) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoEliminarLugar(nombre: lugar.nombre),
    );
    if (!mounted) return;
    if (confirmado == true) {
      await viewModel.eliminarLugar(lugar.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lugares Frecuentes',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const PantallaFormularioLugarFrecuente(),
            ),
          );
          if (!mounted) return;
          if (ok == true) {
            viewModel.cargarLugares();
          }
        },
        backgroundColor: const Color(0xFF0F766E), // <-- tu color
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
                  'No hay lugares guardados',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              );
            }

            return ReorderableListView.builder(
              itemCount: viewModel.lugares.length,
              onReorder: viewModel.reordenar,
              itemBuilder: (context, index) {
                final lugar = viewModel.lugares[index];
                return Card(
                  key: ValueKey(lugar.id),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Text(
                      _emojiDesdeNombre(lugar.icono),
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      lugar.nombre,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      lugar.direccion,
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF0F766E)),
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          _editarLugar(lugar);
                        } else if (opcion == 'eliminar') {
                          _confirmarEliminar(lugar);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Modificar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  Future<void> _editarLugar(LugarFrecuente lugar) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormularioLugarFrecuente(lugar: lugar),
      ),
    );
    if (!mounted) return;
    if (actualizado == true) {
      viewModel.cargarLugares();
    }
  }

  String _emojiDesdeNombre(String icono) {
    switch (icono) {
      case 'home':
        return '🏠';
      case 'factory':
        return '🏭';
      case 'location_on':
        return '📍';
      case 'work':
        return '💼';
      case 'school':
        return '🎓';
      case 'local_gym':
        return '🏋️';
      case 'shopping_cart':
        return '🛒';
      default:
        return icono;
    }
  }
}

class _DialogoEliminarLugar extends StatefulWidget {
  final String nombre;
  const _DialogoEliminarLugar({required this.nombre});
  @override
  State<_DialogoEliminarLugar> createState() => _DialogoEliminarLugarState();
}

class _DialogoEliminarLugarState extends State<_DialogoEliminarLugar> {
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
      title: const Text('Eliminar lugar'),
      content: Text(
        'Se eliminará "${widget.nombre}".\n\n${ok ? '¿Confirmás?' : 'Podrás confirmar en $_segundos seg.'}',
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