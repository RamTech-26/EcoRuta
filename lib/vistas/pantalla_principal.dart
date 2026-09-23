import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 36, color: const Color(0xFF0F766E)), // <-- tu color
              const SizedBox(height: 8),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EcoRuta',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: viewModel.controladorBusqueda,
                  decoration: InputDecoration(
                    hintText: 'Origen',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.my_location, color: Color(0xFF0F766E)),
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
                const SizedBox(height: 12),
                TextField(
                  controller: viewModel.controladorDestino,
                  decoration: InputDecoration(
                    hintText: 'Destino',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0F766E)),
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
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: viewModel.cerrarPanel,
                  child: Container(
                    color: Colors.grey[200],
                    child: const Center(child: Text('Mapa')),
                  ),
                ),
                DraggableScrollableSheet(
                  controller: viewModel.controladorPanel,
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  maxChildSize: 0.8,
                  snap: true,
                  snapSizes: const [0.1, 0.8],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          // Barrita de arrastre (color 0F766E)
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
                                  color: const Color(0xFF0F766E), // <-- tu color
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),

                          // Grid de 4 baldosas
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
                                      builder: (_) => const PantallaReporteIncidente(),
                                    ),
                                  );
                                },
                              ),
                              _baldosa(Icons.home, 'Lugares Frecuentes', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaListaLugaresFrecuentes(),
                                  ),
                                );
                              }),
                              _baldosa(Icons.alarm, 'Alarmas', () {
                                Navigator.push(
                                  context,
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
                            ],
                          ),

                          // Botón de cerrar sesión
                          const SizedBox(height: 16),
                          SizedBox(
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
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
