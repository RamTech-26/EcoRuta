import 'package:flutter/material.dart';

import '../modelos/lugar_frecuente.dart';
import '../viewmodels/lugar_frecuente_viewmodel.dart';

class PantallaFormularioLugarFrecuente extends StatefulWidget {
  const PantallaFormularioLugarFrecuente({super.key});
  @override
  State<PantallaFormularioLugarFrecuente> createState() =>
      _PantallaFormularioLugarFrecuenteState();
}

class _PantallaFormularioLugarFrecuenteState
    extends State<PantallaFormularioLugarFrecuente> {
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _viewModel = LugarFrecuenteViewModel();
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty || _direccionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos')),
      );
      return;
    }
    setState(() => _guardando = true);
    final lugar = LugarFrecuente(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // teoría: sin paquetes externos
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      latitud: 0,
      longitud: 0,
      icono: 'home',
      orden: 0,
    );
    await _viewModel.agregarLugar(lugar);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (_viewModel.error == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo lugar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
