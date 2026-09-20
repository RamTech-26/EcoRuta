import 'package:flutter/material.dart';

/// Pantalla de puntos del usuario.
/// Tres vistas seleccionables: mes actual, acumulado total y canje.
/// Los datos están hardcodeados por ahora, a la espera de integrarlos
/// con la base de datos y la lógica real de acumulación.
class PantallaPuntos extends StatefulWidget {
  const PantallaPuntos({super.key});

  @override
  State<PantallaPuntos> createState() => _PantallaPuntosState();
}

class _PantallaPuntosState extends State<PantallaPuntos> {
  /// Vista actualmente seleccionada: 0 = mes, 1 = acumulado, 2 = canje.
  int _vistaSeleccionada = 0;

  // --- Datos hardcodeados (temporales) ---

  /// Viajes del mes actual: cada uno con origen, destino, puntos y fecha.
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

  /// Puntajes por mes, del más reciente al más antiguo.
  final List<Map<String, dynamic>> _puntajesPorMes = const [
    {'mes': 'Octubre 2026', 'puntos': 350},
    {'mes': 'Septiembre 2026', 'puntos': 280},
    {'mes': 'Agosto 2026', 'puntos': 410},
    {'mes': 'Julio 2026', 'puntos': 190},
    {'mes': 'Junio 2026', 'puntos': 260},
  ];

  /// Recompensas disponibles para canjear.
  final List<Map<String, dynamic>> _recompensas = const [
    {'nombre': 'Café gratis', 'costo': 100, 'icono': Icons.local_cafe},
    {'nombre': 'Estacionamiento 1 hora', 'costo': 200, 'icono': Icons.local_parking},
    {'nombre': 'Descuento 10% en supermercado', 'costo': 350, 'icono': Icons.local_grocery_store},
    {'nombre': 'Entrada al cine', 'costo': 500, 'icono': Icons.movie},
    {'nombre': 'Bicicleta municipal 1 día', 'costo': 700, 'icono': Icons.pedal_bike},
  ];

  /// Devuelve el puntaje total del mes actual sumando los viajes.
  int get _totalMesActual =>
      _viajesMesActual.fold(0, (suma, v) => suma + (v['puntos'] as int));

  /// Devuelve el puntaje acumulado total sumando todos los meses.
  int get _totalAcumulado =>
      _puntajesPorMes.fold(0, (suma, m) => suma + (m['puntos'] as int));

  /// Devuelve el mes con más puntos (para resaltarlo).
  String get _mesConMasPuntos {
    final mejor = _puntajesPorMes.reduce(
      (a, b) => (a['puntos'] as int) > (b['puntos'] as int) ? a : b,
    );
    return mejor['mes'] as String;
  }

  /// Devuelve el nombre del mes actual en español (ej: "octubre 2026").
  String _nombreMesActual() {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final hoy = DateTime.now();
    return '${meses[hoy.month - 1]} ${hoy.year}';
  }

  // --- Vistas ---

  /// Vista de los viajes del mes actual.
  Widget _vistaMesActual() {
    return Column(
      children: [
        // Encabezado con el total del mes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.green.withOpacity(0.15),
          child: Column(
            children: [
              Text(
                'Puntaje de ${_nombreMesActual()}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalMesActual pts',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.route, color: Colors.green),
                  title: Text(
                    '${viaje['origen']} → ${viaje['destino']}',
                  ),
                  subtitle: Text(
                    viaje['fecha'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text(
                    '+${viaje['puntos']} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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

  /// Vista del puntaje acumulado, resaltando el mes con más puntos.
  Widget _vistaAcumulado() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.blue.withOpacity(0.15),
          child: Column(
            children: [
              const Text(
                'Puntaje acumulado total',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalAcumulado pts',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
              return Card(
                color: esElMejor ? Colors.amber.withOpacity(0.3) : null,
                child: ListTile(
                  leading: Icon(
                    esElMejor ? Icons.emoji_events : Icons.calendar_month,
                    color: esElMejor ? Colors.amber[800] : Colors.blue,
                  ),
                  title: Text(
                    mes['mes'] as String,
                    style: TextStyle(
                      fontWeight: esElMejor ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    '${mes['puntos']} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Vista de recompensas para canjear.
  Widget _vistaCanje() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.purple.withOpacity(0.15),
          child: const Column(
            children: [
              Text(
                'Canje de puntos',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Elegí una recompensa',
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
              return Card(
                child: ListTile(
                  leading: Icon(r['icono'] as IconData, color: Colors.purple),
                  title: Text(r['nombre'] as String),
                  trailing: Text(
                    '${r['costo']} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
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
      appBar: AppBar(title: const Text('Mis Puntos')),
      body: Column(
        children: [
          // Selector de vistas
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Mes actual')),
                ButtonSegment(value: 1, label: Text('Acumulado')),
                ButtonSegment(value: 2, label: Text('Canje')),
              ],
              selected: {_vistaSeleccionada},
              onSelectionChanged: (seleccion) {
                setState(() => _vistaSeleccionada = seleccion.first);
              },
            ),
          ),
          // Vista según la selección
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
    );
  }
}