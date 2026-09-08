import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

class PantallaLogin extends StatelessWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text('Login'), // título
              const SizedBox(height: 20), // espacio vertical
              const TextField(
                // campo de texto para usuario
                decoration: InputDecoration(
                  labelText: 'Usuario', // etiqueta visible
                  border: OutlineInputBorder(), // borde alrededor
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                // campo de texto para usuario
                decoration: InputDecoration(
                  labelText: 'Contraseña', // etiqueta visible
                  border: OutlineInputBorder(), // borde alrededor
                ),
              ),
              const SizedBox(height: 20), // espacio entre contraseña y botón
              ElevatedButton(
                onPressed: () {}, // acción vacía por ahora
                child: const Text('Ingresar Con Google...'), // texto del botón
              ),
              const Spacer(), // espacio entre contraseña y botón
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    // navega a otra pantalla
                    context, // contexto actual
                    MaterialPageRoute(
                      // define la pantalla destino
                      builder: (context) => const PantallaPrincipal(),
                    ),
                  );
                }, // acción vacía por ahora
                child: const Text('Confirmar'), // texto del botón
              ),
            ],
          ),
        ),
      ),
    );
  }
}
