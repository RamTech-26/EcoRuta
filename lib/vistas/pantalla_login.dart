import 'package:flutter/material.dart';

import 'pantalla_principal.dart';
import '../viewmodels/login_viewmodel.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late final LoginViewModel viewModel; // se guarda el ViewModel

  @override
  void initState() {
    super.initState(); // siempre primero
    viewModel = LoginViewModel(); // se crea una sola vez
  }

  @override
  void dispose() {
    viewModel.dispose(); // libera recursos
    super.dispose(); // siempre al final
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel, // escucha los avisos del ViewModel
      builder: (context, child) {
        if (viewModel.logueado) { // si cambió el estado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement( // navega una sola vez
              context,
              MaterialPageRoute(
                builder: (_) => const PantallaPrincipal(),
              ),
            );
          });
        }
        return Scaffold( // dibuja la pantalla
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text('Login'), // título
                  const SizedBox(height: 20), // espacio vertical
                  TextField(
                    // campo de texto para usuario
                    controller: viewModel.controladorUsuario,
                    decoration: const InputDecoration(
                      labelText: 'Usuario', // etiqueta visible
                      border: OutlineInputBorder(), // borde alrededor
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    // campo de texto para contraseña
                    controller: viewModel.controladorContrasena,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña', // etiqueta visible
                      border: OutlineInputBorder(), // borde alrededor
                    ),
                  ),
                  const SizedBox(height: 20), // espacio entre contraseña y botón
                  ElevatedButton(
                    onPressed: viewModel.loginConGoogle, // llama al ViewModel
                    child: const Text('Ingresar Con Google...'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: viewModel.login, // llama al ViewModel
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }, 
    ); 
  }
}