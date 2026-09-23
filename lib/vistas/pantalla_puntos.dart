import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaPuntos extends StatefulWidget {
  const PantallaPuntos({super.key});

  @override
  State<PantallaPuntos> createState() => _PantallaPuntosState();
}

class _PantallaPuntosState extends State<PantallaPuntos> {
  int _vistaSeleccionada = 0;

  final List<Map<String, dynamic>> _viajesMesActual = const [
    {
      'origen': 'Casa',
      'destino': 'Trabajo',
      'puntos': 25,
      'fecha': '30/04 15:50hs salida / 16:15hs llegada',
    },
    {
      'origen': 'Trabajo',
      'destino': 'Gimnasio',
      'puntos': 15,
      'fecha': '30/04 18:20hs salida / 18:35hs llegada',
    },
    {
      'origen': 'Gimnasio',
      'destino': 'Casa',
      'puntos': 20,
      'fecha': '29/04 20:15hs salida / 20:30hs llegada',
    },
    {
      'origen': 'Casa',
      'destino': 'Supermercado',
      'puntos': 10,
      'fecha': '28/04 11:00hs salida / 11:12hs llegada',
    },
  ];

  final List<Map<String, dynamic>> _puntajesPorMes = const [
    {'mes': 'Octubre 2026', 'puntos': 350},
    {'mes': 'Septiembre 2026', 'puntos': 280},
    {'mes': 'Agosto 2026', 'puntos': 410},
    {'mes': 'Julio 2026', 'puntos': 190},
    {'mes': 'Junio 2026', 'puntos': 260},
  ];

  final List<Map<String, dynamic>> _recompensas = const [
    {'nombre': 'Café gratis', 'costo': 100, 'icono': Icons.local_cafe},
    {'nombre': 'Estacionamiento 1 hora', 'costo': 200, 'icono': Icons.local_parking},
    {'nombre': 'Descuento 10% en supermercado', 'costo': 350, 'icono': Icons.local_grocery_store},
    {'nombre': 'Entrada al cine', 'costo': 500, 'icono': Icons.movie},
    {'nombre': 'Bicicleta municipal 1 día', 'costo': 700, 'icono': Icons.pedal_bike},
  ];

  int get _totalMesActual =>
      _viajesMesActual.fold(0, (suma, v) => suma + (v['puntos'] as int));

  int get _totalAcumulado =>
      _puntajesPorMes.fold(0, (suma, m) => suma + (m['puntos'] as int));

  String get _mesConMasPuntos {
    final mejor = _puntajesPorMes.reduce(
      (a, b) => (a['puntos'] as int) > (b['puntos'] as int) ? a : b,
    );
    return mejor['mes'] as String;
  }

  String _nombreMesActual() {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final hoy = DateTime.now();
    return '${meses[hoy.month - 1]} ${hoy.year}';
  }

  Widget _vistaMesActual() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          color: const Color(0xFF0F766E).withOpacity(0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Puntaje de ${_nombreMesActual()}',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalMesActual pts',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _viajesMesActual.length,
            itemBuilder: (context, i) {
              final viaje = _viajesMesActual[i];
              return SizedBox(
                height: 80,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.route, color: Color(0xFF0F766E)),
                    title: Text(
                      '${viaje['origen']} → ${viaje['destino']}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      viaje['fecha'] as String,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Text(
                      '+${viaje['puntos']} pts',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _vistaAcumulado() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          color: const Color(0xFF0F766E).withOpacity(0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Puntaje acumulado total',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalAcumulado pts',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _puntajesPorMes.length,
            itemBuilder: (context, i) {
              final mes = _puntajesPorMes[i];
              final esElMejor = mes['mes'] == _mesConMasPuntos;
              return SizedBox(
                height: 80,
                child: Card(
                  elevation: 3,
                  color: esElMejor ? Colors.amber.withOpacity(0.3) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      esElMejor ? Icons.emoji_events : Icons.calendar_month,
                      color: esElMejor ? Colors.amber[800] : const Color(0xFF0F766E),
                    ),
                    title: Text(
                      mes['mes'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: esElMejor ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      '${mes['puntos']} pts',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _vistaCanje() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          color: const Color(0xFF0F766E).withOpacity(0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Canje de puntos',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Elegí una recompensa',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _recompensas.length,
            itemBuilder: (context, i) {
              final r = _recompensas[i];
              return SizedBox(
                height: 80,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(r['icono'] as IconData, color: const Color(0xFF0F766E)),
                    title: Text(
                      r['nombre'] as String,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      '${r['costo']} pts',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Puntos',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Mes actual',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Acumulado',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Canje',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
                selected: {_vistaSeleccionada},
                onSelectionChanged: (seleccion) {
                  setState(() => _vistaSeleccionada = seleccion.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF0F766E);
                    }
                    return Colors.grey.shade200;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black87;
                  }),
                ),
              ),
            ),
            Expanded(
              child: switch (_vistaSeleccionada) {
                0 => _vistaMesActual(),
                1 => _vistaAcumulado(),
                2 => _vistaCanje(),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}