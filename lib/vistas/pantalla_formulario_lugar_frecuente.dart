import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modelos/lugar_frecuente.dart';
import '../repositorios/alarma_repositorio.dart';
import '../servicios/alarma_servicio.dart';
import '../servicios/database_helper.dart';
import '../servicios/lugar_frecuente_servicio.dart';
import '../viewmodels/lugar_frecuente_viewmodel.dart';

const List<String> _emojisDisponibles = [
  '🏠',
  '🏭',
  '📍',
  '💼',
  '🎓',
  '\u{1F3CB}\u{FE0F}', // 🏋️
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
  late final LugarFrecuenteViewModel _viewModel;
  bool _guardando = false;
  String _iconoSeleccionado = '🏠';

  bool get _esEdicion => widget.lugar != null;

  @override
  void initState() {
    super.initState();
    final dbHelper = DatabaseHelper();
    final lugarServicio = LugarFrecuenteServicio();
    final alarmaRepositorio = AlarmaRepositorioImpl(dbHelper);
    final alarmaServicio = AlarmaServicio();
    _viewModel = LugarFrecuenteViewModel(
      lugarServicio: lugarServicio,
      alarmaRepositorio: alarmaRepositorio,
      alarmaServicio: alarmaServicio,
    );
    if (_esEdicion) {
      _nombreCtrl.text = widget.lugar!.nombre;
      _direccionCtrl.text = widget.lugar!.direccion;
      _iconoSeleccionado = widget.lugar!.emoji;
      _viewModel.cargarUbicacion(widget.lugar!.latitud, widget.lugar!.longitud);
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
    if (!_viewModel.tieneUbicacion) {
      final seguir = await _confirmarSinUbicacion();
      if (seguir != true || !mounted) return;
    }
    setState(() => _guardando = true);

    final latitud = _viewModel.latitud ?? 0;
    final longitud = _viewModel.longitud ?? 0;

    final lugar = _esEdicion
        ? widget.lugar!.copyWith(
            nombre: _nombreCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            latitud: latitud,
            longitud: longitud,
            icono: _iconoSeleccionado,
          )
        : LugarFrecuente(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: _nombreCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
            latitud: latitud,
            longitud: longitud,
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

  Future<bool?> _confirmarSinUbicacion() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lugar sin ubicación'),
        content: const Text(
          'No cargaste la ubicación de este lugar. Podés guardarlo igual, '
          'pero después no se va a poder usar para sugerir rutas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar igual'),
          ),
        ],
      ),
    );
  }

  Widget _seccionUbicacion() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: vm.obteniendoUbicacion ? null : vm.obtenerUbicacion,
              icon: vm.obteniendoUbicacion
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                vm.tieneUbicacion
                    ? 'Actualizar con mi ubicación actual'
                    : 'Usar mi ubicación actual',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F766E),
                side: const BorderSide(color: Color(0xFF0F766E)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (vm.avisoUbicacion != null)
              Text(
                vm.avisoUbicacion!,
                style: const TextStyle(color: Colors.red),
              )
            else if (vm.tieneUbicacion)
              Text(
                'Ubicación: ${vm.latitud!.toStringAsFixed(5)}, '
                '${vm.longitud!.toStringAsFixed(5)}',
                style: const TextStyle(color: Colors.black54),
              )
            else
              const Text(
                'Sin ubicación cargada',
                style: TextStyle(color: Colors.black54),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: SingleChildScrollView(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F766E),
                      width: 2.5,
                    ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F766E),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _seccionUbicacion(),
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
                runSpacing: 12,
                children: _emojisDisponibles.map((emoji) {
                  final seleccionado = _iconoSeleccionado == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _iconoSeleccionado = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFF0F766E).withValues(alpha: 0.2)
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
}
