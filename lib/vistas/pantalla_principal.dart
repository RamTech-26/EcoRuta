import 'package:flutter/material.dart';

import 'pantalla_reporte_incidente.dart';
import '../viewmodels/principal_viewmodel.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final PrincipalViewModel viewModel; // se guarda el ViewModel

  @override
  void initState() {
    super.initState(); // siempre primero
    viewModel = PrincipalViewModel(); // se crea una sola vez
  }

  @override
  void dispose() {
    viewModel.dispose(); // libera recursos
    super.dispose(); // siempre al final
  }

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
                  controller:
                      viewModel.controladorBusqueda, // conecta con el ViewModel
                  decoration: const InputDecoration(
                    hintText: 'Buscar Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller:
                      viewModel.controladorDestino, // conecta con el ViewModel
                  decoration: const InputDecoration(
                    hintText: 'Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: const Center(child: Text('Mapa')),
                  ),
                ),
              ],
            ),
            DraggableScrollableSheet(
              controller:
                  viewModel.controladorPanel, // conecta con el ViewModel
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.35,
              snap: true,
              snapSizes: const [0.1, 0.35],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 161, 252, 255),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      GestureDetector(
                        onTap: viewModel.alternarPanel, // al tocar, sube o baja
                        child: Container(
                          height: 30,
                          alignment: Alignment.topCenter,
                          color: Colors.transparent,
                          child: Container(
                            width: 60,
                            height: 6,
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 150, 7, 7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Opciones',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
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
        onTap: onTap,
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
