import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modelos/alarma.dart';
import '../modelos/lugar_frecuente.dart';
import '../servicios/lugar_frecuente_servicio.dart';
import '../viewmodels/alarma_viewmodel.dart';

class PantallaFormularioAlarma extends StatefulWidget {
  final AlarmaViewModel viewModel;
  final Alarma? alarmaEditar;

  const PantallaFormularioAlarma({
    super.key,
    required this.viewModel,
    this.alarmaEditar,
  });

  @override
  State<PantallaFormularioAlarma> createState() =>
      _PantallaFormularioAlarmaState();
}

class _PantallaFormularioAlarmaState extends State<PantallaFormularioAlarma> {
  final LugarFrecuenteServicio _lugarServicio = LugarFrecuenteServicio();
  final List<String> _diasSemana = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  List<LugarFrecuente> _lugares = [];
  String? _lugarIdSeleccionado;
  TimeOfDay? _horaSeleccionada;
  List<String> _diasSeleccionados = [];

  bool _loopAudio = true;
  bool _vibrar = true;
  String _sonido = 'Marimba';
  bool _volumenPersonalizado = false;
  double _volumen = 0.8;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    final lugares = await _lugarServicio.obtenerTodos();
    if (!mounted) return;

    final a = widget.alarmaEditar;
    setState(() {
      _lugares = lugares;
      if (a != null) {
        _lugarIdSeleccionado = a.lugarId;
        final partes = a.hora.split(':');
        _horaSeleccionada = TimeOfDay(
          hour: int.parse(partes[0]),
          minute: int.parse(partes[1]),
        );
        _diasSeleccionados =
            a.dias.isEmpty
                ? []
                : a.dias.split(', ').map((e) => e.trim()).toList();
        _loopAudio = a.loopAudio;
        _vibrar = a.vibrar;
        _sonido = a.sonido;
        _volumenPersonalizado = a.volumenPersonalizado;
        _volumen = a.volumen;
      }
      _cargando = false;
    });
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );
    if (hora != null && mounted) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  void _guardar() {
    if (_lugarIdSeleccionado == null ||
        _horaSeleccionada == null ||
        _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá lugar, hora y al menos un día'),
        ),
      );
      return;
    }

    final horaStr = _horaSeleccionada!.hour.toString().padLeft(2, '0');
    final minutoStr = _horaSeleccionada!.minute.toString().padLeft(2, '0');

    final alarmaActualizada = Alarma(
      id: widget.alarmaEditar?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lugarId: _lugarIdSeleccionado!,
      hora: '$horaStr:$minutoStr',
      dias: _diasSeleccionados.join(', '),
      activa: widget.alarmaEditar?.activa ?? true,
      orden: widget.alarmaEditar?.orden ?? widget.viewModel.alarmas.length,
      loopAudio: _loopAudio,
      vibrar: _vibrar,
      sonido: _sonido,
      volumenPersonalizado: _volumenPersonalizado,
      volumen: _volumen,
    );

    widget.viewModel.guardarAlarma(alarmaActualizada);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: _guardar,
            child: Text(
              'Guardar',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF0F766E),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Center(
                    child: InkWell(
                      onTap: _seleccionarHora,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _horaSeleccionada == null
                              ? '00:00'
                              : _horaSeleccionada!.format(context),
                          style: GoogleFonts.poppins(
                            fontSize: 44,
                            color: const Color(0xFF0F766E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Lugar Frecuente',
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
                    initialValue: _lugarIdSeleccionado,
                    items: _lugares.map((lugar) {
                      return DropdownMenuItem(
                        value: lugar.id,
                        child: Text(lugar.nombre, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _lugarIdSeleccionado = v),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Días de activación:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _diasSemana.map((dia) {
                      final sel = _diasSeleccionados.contains(dia);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            sel ? _diasSeleccionados.remove(dia) : _diasSeleccionados.add(dia);
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? const Color(0xFF0F766E) : Colors.grey.shade200,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dia.substring(0, 1),
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: Text('Repetición', style: GoogleFonts.poppins()),
                    value: _loopAudio,
                    activeColor: const Color(0xFF0F766E),
                    onChanged: (v) => setState(() => _loopAudio = v),
                  ),
                  SwitchListTile(
                    title: Text('Vibración', style: GoogleFonts.poppins()),
                    value: _vibrar,
                    activeColor: const Color(0xFF0F766E),
                    onChanged: (v) => setState(() => _vibrar = v),
                  ),
                  ListTile(
                    title: Text('Sonido', style: GoogleFonts.poppins()),
                    trailing: DropdownButton<String>(
                      value: _sonido,
                      underline: const SizedBox(),
                      items: ['Marimba', 'Nokia', 'Samsung']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins())))
                          .toList(),
                      onChanged: (v) => setState(() => _sonido = v!),
                    ),
                  ),
                  SwitchListTile(
                    title: Text('Volumen personalizado', style: GoogleFonts.poppins()),
                    value: _volumenPersonalizado,
                    activeColor: const Color(0xFF0F766E),
                    onChanged: (v) => setState(() => _volumenPersonalizado = v),
                  ),
                  if (_volumenPersonalizado)
                    Row(
                      children: [
                        const Icon(Icons.volume_down, color: Color(0xFF0F766E)),
                        Expanded(
                          child: Slider(
                            value: _volumen,
                            activeColor: const Color(0xFF0F766E),
                            onChanged: (v) => setState(() => _volumen = v),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}