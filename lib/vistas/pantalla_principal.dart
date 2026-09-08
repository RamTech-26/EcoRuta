import 'package:flutter/material.dart';

import 'pantalla_reporte_incidente.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: Center(child: Text('Mapa')),
                  ),
                ),
              ],
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.35,
              snap: true,
              snapSizes: [0.1, 0.35],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 161, 252, 255),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 150, 7, 7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Opciones',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12), // antes 16
                        mainAxisSpacing: 12, // antes 16
                        crossAxisSpacing: 12, // antes 16
                        childAspectRatio: 2.2, // baldosas más anchas que altas
                        children: [
                          _Baldosa(
                            icono: Icons.map,
                            etiqueta: 'Destino',
                            onTap: () {},
                          ),
                          _Baldosa(
                            icono: Icons.alarm,
                            etiqueta: 'Alarmas',
                            onTap: () {},
                          ),
                          _Baldosa(
                            icono: Icons.report,
                            etiqueta: 'Reportar Incidente',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PantallaReporteIncidente(),
                                ),
                              );
                            },
                          ),
                          _Baldosa(
                            icono: Icons.star,
                            etiqueta: 'Puntos',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Baldosa extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _Baldosa({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap, // ← usa la acción recibida
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 28),
            const SizedBox(height: 4),
            Text(etiqueta, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
