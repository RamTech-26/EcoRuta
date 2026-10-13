import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/registro_viewmodel.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  late final RegistroViewModel viewModel;

  final TextEditingController controladorNombreApellido = TextEditingController();
  final TextEditingController controladorUsuario = TextEditingController();
  final TextEditingController controladorDni = TextEditingController();
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();
  final TextEditingController controladorRepetirContrasena = TextEditingController();
  final TextEditingController controladorPais = TextEditingController();
  final TextEditingController controladorCiudad = TextEditingController();
  final TextEditingController controladorDepartamento = TextEditingController();
  bool _ocultarContrasena = true;
  bool _ocultarRepetirContrasena = true;

  @override
  void initState() {
    super.initState();
    viewModel = RegistroViewModel();
  }

  @override
  void dispose() {
    controladorNombreApellido.dispose();
    controladorUsuario.dispose();
    controladorDni.dispose();
    controladorEmail.dispose();
    controladorContrasena.dispose();
    controladorRepetirContrasena.dispose();
    controladorPais.dispose();
    controladorCiudad.dispose();
    controladorDepartamento.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmarRegistro() async {
    final valido = viewModel.validarCampos(
      nombreApellido: controladorNombreApellido.text,
      usuario: controladorUsuario.text,
      dni: controladorDni.text,
      email: controladorEmail.text,
      contrasena: controladorContrasena.text,
      repetirContrasena: controladorRepetirContrasena.text,
      pais: controladorPais.text,
      ciudad: controladorCiudad.text,
      departamento: controladorDepartamento.text,
    );
    if (!valido) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar registro'),
        content: const Text('¿Estás seguro que querés registrarte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await viewModel.registrar(
      nombreApellido: controladorNombreApellido.text,
      usuario: controladorUsuario.text,
      dni: controladorDni.text,
      email: controladorEmail.text,
      contrasena: controladorContrasena.text,
      repetirContrasena: controladorRepetirContrasena.text,
      pais: controladorPais.text,
      ciudad: controladorCiudad.text,
      departamento: controladorDepartamento.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.registrado) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuario registrado correctamente')),
            );
            Navigator.pop(context);
          });
        }

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
              color: Colors.black.withOpacity(0.4),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Registro',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Campo: nombre y apellido
                      TextField(
                        controller: controladorNombreApellido,
                        decoration: InputDecoration(
                          hintText: 'Nombre y apellido',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorNombreApellido,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: usuario
                      TextField(
                        controller: controladorUsuario,
                        decoration: InputDecoration(
                          hintText: 'Usuario',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorUsuario,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: DNI
                      TextField(
                        controller: controladorDni,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'DNI',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorDni,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: email
                      TextField(
                        controller: controladorEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorEmail,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: contraseña
                      TextField(
                        controller: controladorContrasena,
                        obscureText: _ocultarContrasena,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorContrasena,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarContrasena = !_ocultarContrasena;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: repetir contraseña
                      TextField(
                        controller: controladorRepetirContrasena,
                        obscureText: _ocultarRepetirContrasena,
                        decoration: InputDecoration(
                          hintText: 'Repetir contraseña',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorRepetirContrasena,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarRepetirContrasena ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarRepetirContrasena = !_ocultarRepetirContrasena;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: país
                      TextField(
                        controller: controladorPais,
                        decoration: InputDecoration(
                          hintText: 'País',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorPais,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: ciudad
                      TextField(
                        controller: controladorCiudad,
                        decoration: InputDecoration(
                          hintText: 'Ciudad',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorCiudad,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: departamento
                      TextField(
                        controller: controladorDepartamento,
                        decoration: InputDecoration(
                          hintText: 'Departamento',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2.5),
                          ),
                          errorText: viewModel.errorDepartamento,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mensaje de error general
                      if (viewModel.errorGeneral != null)
                        Text(
                          viewModel.errorGeneral!,
                          style: const TextStyle(color: Colors.red),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: viewModel.cargando ? null : _confirmarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                          ),
                          child: viewModel.cargando
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('REGISTRAR'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: viewModel.cargando
                            ? null
                            : () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '¿Ya tenés cuenta? ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Iniciá sesión',
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
            ),
          ),
        );
      },
    );
  }
}