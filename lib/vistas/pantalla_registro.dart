import 'package:flutter/material.dart';

import '../viewmodels/registro_viewmodel.dart';

/// Pantalla de registro de un usuario nuevo.
/// Valida cada campo, guarda en la base de datos y luego navega al login.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  late final RegistroViewModel viewModel;

  // Controllers de cada campo (viven en la vista, no en el ViewModel)
  final TextEditingController controladorNombreApellido =
      TextEditingController();
  final TextEditingController controladorUsuario = TextEditingController();
  final TextEditingController controladorDni = TextEditingController();
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorContrasena = TextEditingController();
  final TextEditingController controladorRepetirContrasena =
      TextEditingController();
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

  /// Muestra un diálogo para confirmar el registro.
  Future<void> _confirmarRegistro() async {
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
        // Si se registró correctamente, avisa y vuelve al login
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
          appBar: AppBar(title: const Text('Registro')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Campo: nombre y apellido
                  TextField(
                    controller: controladorNombreApellido,
                    decoration: InputDecoration(
                      labelText: 'Nombre y apellido',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorNombreApellido,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: usuario
                  TextField(
                    controller: controladorUsuario,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorUsuario,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: DNI
                  TextField(
                    controller: controladorDni,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorDni,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: email
                  TextField(
                    controller: controladorEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorEmail,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: contraseña
                  TextField(
                    controller: controladorContrasena,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorContrasena,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                      labelText: 'Repetir contraseña',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorRepetirContrasena,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarRepetirContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _ocultarRepetirContrasena =
                                !_ocultarRepetirContrasena;
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
                      labelText: 'País',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorPais,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: ciudad
                  TextField(
                    controller: controladorCiudad,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorCiudad,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campo: departamento
                  TextField(
                    controller: controladorDepartamento,
                    decoration: InputDecoration(
                      labelText: 'Departamento',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.errorDepartamento,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mensaje de error general (si falla el guardado)
                  if (viewModel.errorGeneral != null)
                    Text(
                      viewModel.errorGeneral!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  // Botones: Cancelar y Confirmar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.cargando
                              ? null
                              : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.cargando
                              ? null
                              : _confirmarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: viewModel.cargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Confirmar'),
                        ),
                      ),
                    ],
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
