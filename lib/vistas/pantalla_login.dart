import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../repositorios/auth_repositorio.dart';
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
  bool _inicializado = false;
  bool _navegando = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      viewModel = LoginViewModel(repositorio: context.read<AuthRepositorio>());
      viewModel.addListener(_alCambiarEstado);
      _inicializado = true;
    }
  }

  /// Abre la pantalla principal una sola vez cuando el login sale bien.
  ///
  /// No va en el `build`: el `build` se ejecuta muchas veces (por ejemplo,
  /// mientras se cierra el teclado) y abría varias copias de la pantalla.
  void _alCambiarEstado() {
    if (!viewModel.logueado || _navegando || !mounted) return;
    _navegando = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
    );
  }

  @override
  void dispose() {
    if (_inicializado) viewModel.removeListener(_alCambiarEstado);
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
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height - 48,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          if (viewModel.error != null)
                            Text(
                              viewModel.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controladorUsuario,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controladorContrasena,
                            obscureText: viewModel.ocultarContrasena,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 2.5,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  viewModel.ocultarContrasena
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed:
                                    viewModel.alternarVisibilidadContrasena,
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                              ),
                              child: viewModel.cargando
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('INICIAR SESIÓN'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white54,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'o',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white54,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: viewModel.cargando
                                  ? null
                                  : () => viewModel.loginConGoogle(),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google-logo.png',
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Continuar con Google'),
                                ],
                              ),
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
                                        builder: (_) =>
                                            const PantallaRegistro(),
                                      ),
                                    );
                                  },
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '¿No tenés cuenta? ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'Registrate',
                                    style: TextStyle(
                                      color: Color(0xFF0F766E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Text(
                      'EcoRuta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
