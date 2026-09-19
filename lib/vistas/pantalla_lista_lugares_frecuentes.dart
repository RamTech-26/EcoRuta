import 'package:flutter/material.dart';
import 'dart:async';
import '../viewmodels/lugar_frecuente_viewmodel.dart';
import '../modelos/lugar_frecuente.dart';
import 'pantalla_formulario_lugar_frecuente.dart';

class PantallaListaLugaresFrecuentes extends StatefulWidget {
  const PantallaListaLugaresFrecuentes({super.key});
  @override
  State<PantallaListaLugaresFrecuentes> createState() => _PantallaListaLugaresFrecuentesState();
}

class _PantallaListaLugaresFrecuentesState extends State<PantallaListaLugaresFrecuentes> {
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
      appBar: AppBar(title: const Text('Lugares Frecuentes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PantallaFormularioLugarFrecuente()),
          );
          if (!mounted) return;
          if (ok == true) {
            viewModel.cargarLugares();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.cargando) return const Center(child: CircularProgressIndicator());
          if (viewModel.error!= null) return Center(child: Text(viewModel.error!));
          if (viewModel.estaVacio) return const Center(child: Text('No hay lugares guardados'));

          return ReorderableListView.builder(
            itemCount: viewModel.lugares.length,
            onReorder: viewModel.reordenar,
            itemBuilder: (context, index) {
              final lugar = viewModel.lugares[index];
              return ListTile(
                key: ValueKey(lugar.id),
                leading: const Icon(Icons.location_on),
                title: Text(lugar.nombre),
                subtitle: Text(lugar.direccion),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarEliminar(lugar),
                ),
              );
            },
          );
        },
      ),
    );
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
      content: Text('Se eliminará "${widget.nombre}".\n\n${ok? '¿Confirmás?' : 'Podrás confirmar en $_segundos seg.'}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: ok? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: Text(ok? 'Eliminar' : 'Eliminar ($_segundos)'),
        ),
      ],
    );
  }
}