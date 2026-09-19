import 'package:flutter/material.dart';

import '../viewmodels/login_viewmodel.dart';
import 'pantalla_principal.dart';
import 'pantalla_registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});
  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late final LoginViewModel viewModel;
  final TextEditingController controladorUsuario = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    controladorUsuario.dispose();
    controladorContrasena.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.logueado) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
            );
          });
        }
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'EcoRuta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (viewModel.error != null)
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: controladorUsuario,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controladorContrasena,
                  obscureText: viewModel.ocultarContrasena,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.ocultarContrasena
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: viewModel.alternarVisibilidadContrasena,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: viewModel.cargando
                        ? null
                        : () => viewModel.login(
                            controladorUsuario.text,
                            controladorContrasena.text,
                          ),
                    child: viewModel.cargando
                        ? const CircularProgressIndicator()
                        : const Text('Confirmar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: viewModel.cargando
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Login con Google todavía no está disponible',
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Continuar con Google'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: viewModel.cargando
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PantallaRegistro(),
                            ),
                          );
                        },
                  child: const Text('¿No tenés cuenta? Registrate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
