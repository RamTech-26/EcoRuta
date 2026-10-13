import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modelos/lugar_frecuente.dart';
import '../viewmodels/lugar_frecuente_viewmodel.dart';

const List<String> _emojisDisponibles = [
  '🏠',
  '🏭',
  '📍',
  '💼',
  '🎓',
  '🏋️',
  '🛒',
];

class PantallaFormularioLugarFrecuente extends StatefulWidget {
  final LugarFrecuente? lugar;

  const PantallaFormularioLugarFrecuente({super.key, this.lugar});

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
  String _iconoSeleccionado = '🏠';

  bool get _esEdicion => widget.lugar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.lugar!.nombre;
      _direccionCtrl.text = widget.lugar!.direccion;
      _iconoSeleccionado = _emojiDesdeNombre(widget.lugar!.icono);
    }
  }

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

    final lugar = _esEdicion
        ? widget.lugar!.copyWith(
            nombre: _nombreCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            icono: _iconoSeleccionado,
          )
        : LugarFrecuente(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: _nombreCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            latitud: 0,
            longitud: 0,
            icono: _iconoSeleccionado,
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
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Modificar lugar' : 'Nuevo lugar',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  hintText: 'Nombre',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _direccionCtrl,
                decoration: InputDecoration(
                  hintText: 'Dirección',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Elegí un ícono:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _emojisDisponibles.map((emoji) {
                  final seleccionado = _iconoSeleccionado == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _iconoSeleccionado = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFF0F766E).withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: seleccionado
                              ? const Color(0xFF0F766E)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _esEdicion ? 'Guardar cambios' : 'Guardar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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