import 'package:flutter/material.dart';

import 'pantalla_principal.dart';
import '../viewmodels/login_viewmodel.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late final LoginViewModel viewModel;                          // ViewModel
  final TextEditingController controladorUsuario =
      TextEditingController();                                  // campo usuario
  final TextEditingController controladorContrasena =
      TextEditingController();                                  // campo contraseña

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel();                               // se crea el ViewModel
  }

  @override
  void dispose() {
    controladorUsuario.dispose();                               // libera controller
    controladorContrasena.dispose();                            // libera controller
    viewModel.dispose();                                        // libera ViewModel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,                                    // escucha al ViewModel
      builder: (context, child) {
        if (viewModel.logueado) {                               // si cambió el estado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const PantallaPrincipal(),
              ),
            );
          });
        }
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text('Login'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controladorUsuario,             // controller local
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controladorContrasena,          // controller local
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.loginConGoogle,        // sin parámetros
                    child: const Text('Ingresar Con Google...'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => viewModel.login(           // pasa las credenciales
                      controladorUsuario.text,
                      controladorContrasena.text,
                    ),
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