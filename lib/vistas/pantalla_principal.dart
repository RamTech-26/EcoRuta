import 'package:flutter/material.dart';

import '../viewmodels/principal_viewmodel.dart';
import 'pantalla_lista_lugares_frecuentes.dart';
import 'pantalla_reporte_incidente.dart';
import 'pantalla_puntos.dart';
import 'pantalla_alarmas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pantalla_login.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final PrincipalViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PrincipalViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _baldosa(IconData icono, String titulo, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 36, color: Colors.green),
              const SizedBox(height: 8),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoRuta')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: viewModel.controladorBusqueda,
                  decoration: const InputDecoration(
                    labelText: 'Origen',
                    prefixIcon: Icon(Icons.my_location),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: viewModel.controladorDestino,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text('Mapa')),
                ),
                DraggableScrollableSheet(
                  controller: viewModel.controladorPanel,
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  maxChildSize: 0.4,
                  snap: true,
                  snapSizes: const [0.1, 0.4],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          GestureDetector(
                            onTap: viewModel.alternarPanel,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              height: 50,
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
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: [
                              _baldosa(
                                Icons.warning_amber,
                                'Reportar Incidente',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PantallaReporteIncidente(),
                                    ),
                                  );
                                },
                              ),
                              _baldosa(Icons.home, 'Lugares Frecuentes', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PantallaListaLugaresFrecuentes(),
                                  ),
                                );
                              }),
                              _baldosa(Icons.alarm, 'Alarmas', () {
                                // PASO 1: Navigator.push le pide a Flutter que agregue una pantalla nueva "arriba" de la actual.
                                Navigator.push(
                                  context,
                                  // PASO 2: MaterialPageRoute define CUÁL pantalla abrir: en este caso, PantallaAlarmas[cite: 8].
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaAlarmas(),
                                  ),
                                );
                              }),
                              _baldosa(Icons.stars, 'Mis Puntos', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaPuntos(),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),  // <-- Espacio
                              SizedBox(                    // <-- Botón de cerrar sesión
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    await GoogleSignIn().signOut();
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PantallaLogin()),
                                    );
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Cerrar sesión'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC62828),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
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
        ],
      ),
    );
  }
}
