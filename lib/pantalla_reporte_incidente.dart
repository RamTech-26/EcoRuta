import 'package:flutter/material.dart';

class PantallaReporteIncidente extends StatefulWidget {
  // necesita estado para la selección
  const PantallaReporteIncidente({super.key});

  @override
  State<PantallaReporteIncidente> createState() =>
      _PantallaReporteIncidenteState();
}

class _PantallaReporteIncidenteState extends State<PantallaReporteIncidente> {
  final List<String> _incidentesSeleccionados = [];
  final TextEditingController _controladorDescripcion =
      TextEditingController(); // guarda el texto de "Otros"

  @override
  void dispose() {
    _controladorDescripcion.dispose(); // libera recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Incidente'), // título de la barra
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180, // altura del cuadrado
              decoration: BoxDecoration(
                color: Colors.grey[300], // gris claro de fondo
                borderRadius: BorderRadius.circular(12), // esquinas redondeadas
              ),
              child: Center(
                // centra el contenido
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50), // ícono de cámara
                    SizedBox(height: 8),
                    Text('Adjuntar foto'), // texto indicativo
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              // ocupa el espacio restante
              child: ListView(
                // lista desplazable
                children: [
                  CheckboxListTile(
                    // incidente 1
                    title: const Text('Choque'),
                    value: _incidentesSeleccionados.contains('Choque'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Choque');
                        } else {
                          _incidentesSeleccionados.remove('Choque');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 2
                    title: const Text('Semáforo roto'),
                    value: _incidentesSeleccionados.contains('Semáforo roto'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Semáforo roto');
                        } else {
                          _incidentesSeleccionados.remove('Semáforo roto');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 3
                    title: const Text('Accidente'),
                    value: _incidentesSeleccionados.contains('Accidente'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Accidente');
                        } else {
                          _incidentesSeleccionados.remove('Accidente');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 4
                    title: const Text('Ruta rota'),
                    value: _incidentesSeleccionados.contains('Ruta rota'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Ruta rota');
                        } else {
                          _incidentesSeleccionados.remove('Ruta rota');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 5
                    title: const Text('Inundación'),
                    value: _incidentesSeleccionados.contains('Inundación'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Inundación');
                        } else {
                          _incidentesSeleccionados.remove('Inundación');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    // incidente 6
                    title: const Text('Otros'),
                    value: _incidentesSeleccionados.contains('Otros'),
                    onChanged: (bool? seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _incidentesSeleccionados.add('Otros');
                        } else {
                          _incidentesSeleccionados.remove('Otros');
                        }
                      });
                    },
                  ),
                  if (_incidentesSeleccionados.contains('Otros'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controladorDescripcion,
                        maxLines: 4, // permite varias líneas
                        keyboardType: TextInputType
                            .multiline, // teclado para texto extenso
                        maxLength: 200, // máximo 200 caracteres
                        decoration: InputDecoration(
                          hintText: 'Describí el incidente...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16), // espacio antes del botón
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // vuelve a PantallaPrincipal
              },
              child: const Text('Volver'), // texto del botón
            ),
          ],
        ),
      ),
    );
  }
}
