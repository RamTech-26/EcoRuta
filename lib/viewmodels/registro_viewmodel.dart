import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/usuario.dart';
import '../servicios/usuario_servicio.dart';

/// ViewModel de la pantalla de registro.
/// Valida los campos, guarda el usuario en la base de datos
/// y expone el estado de carga y los errores por campo.
class RegistroViewModel extends ChangeNotifier {
  final UsuarioServicio _servicio = UsuarioServicio();

  bool _cargando = false;
  bool _registrado = false;
  String? _errorGeneral;

  // Errores individuales por campo (se muestran en rojo debajo de cada uno)
  String? _errorNombreApellido;
  String? _errorUsuario;
  String? _errorDni;
  String? _errorEmail;
  String? _errorContrasena;
  String? _errorRepetirContrasena;
  String? _errorPais;
  String? _errorCiudad;
  String? _errorDepartamento;

  bool get cargando => _cargando;
  bool get registrado => _registrado;
  String? get errorGeneral => _errorGeneral;

  String? get errorNombreApellido => _errorNombreApellido;
  String? get errorUsuario => _errorUsuario;
  String? get errorDni => _errorDni;
  String? get errorEmail => _errorEmail;
  String? get errorContrasena => _errorContrasena;
  String? get errorRepetirContrasena => _errorRepetirContrasena;
  String? get errorPais => _errorPais;
  String? get errorCiudad => _errorCiudad;
  String? get errorDepartamento => _errorDepartamento;

  /// Limpia todos los errores antes de una nueva validación.
  void _limpiarErrores() {
    _errorGeneral = null;
    _errorNombreApellido = null;
    _errorUsuario = null;
    _errorDni = null;
    _errorEmail = null;
    _errorContrasena = null;
    _errorRepetirContrasena = null;
    _errorPais = null;
    _errorCiudad = null;
    _errorDepartamento = null;
  }

  /// Valida todos los campos sin guardar nada.
  /// Devuelve true si todo está correcto.
  bool validarCampos({
    required String nombreApellido,
    required String usuario,
    required String dni,
    required String email,
    required String contrasena,
    required String repetirContrasena,
    required String pais,
    required String ciudad,
    required String departamento,
  }) {
    _limpiarErrores();
    bool valido = true;

    if (nombreApellido.trim().isEmpty) {
      _errorNombreApellido = 'Completá nombre y apellido';
      valido = false;
    }
    if (usuario.trim().isEmpty) {
      _errorUsuario = 'Completá el usuario';
      valido = false;
    }
    if (dni.trim().isEmpty) {
      _errorDni = 'Completá el DNI';
      valido = false;
    }
    if (email.trim().isEmpty) {
      _errorEmail = 'Completá el email';
      valido = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      _errorEmail = 'Email inválido';
      valido = false;
    }
    if (contrasena.isEmpty) {
      _errorContrasena = 'Completá la contraseña';
      valido = false;
    } else if (contrasena.length < 6) {
      _errorContrasena = 'Mínimo 6 caracteres';
      valido = false;
    }
    if (repetirContrasena.isEmpty) {
      _errorRepetirContrasena = 'Repetí la contraseña';
      valido = false;
    } else if (contrasena != repetirContrasena) {
      _errorRepetirContrasena = 'Las contraseñas no coinciden';
      valido = false;
    }
    if (pais.trim().isEmpty) {
      _errorPais = 'Completá el país';
      valido = false;
    }
    if (ciudad.trim().isEmpty) {
      _errorCiudad = 'Completá la ciudad';
      valido = false;
    }
    if (departamento.trim().isEmpty) {
      _errorDepartamento = 'Completá el departamento';
      valido = false;
    }

    notifyListeners();
    return valido;
  }

  /// Registra un usuario nuevo en la base de datos.
  /// Primero valida los campos; si ya están validados por la vista
  /// (que llamó a validarCampos antes del diálogo), esta validación
  /// interna es por seguridad.
  Future<void> registrar({
    required String nombreApellido,
    required String usuario,
    required String dni,
    required String email,
    required String contrasena,
    required String repetirContrasena,
    required String pais,
    required String ciudad,
    required String departamento,
  }) async {
    final valido = validarCampos(
      nombreApellido: nombreApellido,
      usuario: usuario,
      dni: dni,
      email: email,
      contrasena: contrasena,
      repetirContrasena: repetirContrasena,
      pais: pais,
      ciudad: ciudad,
      departamento: departamento,
    );

    if (!valido) return;

    _cargando = true;
    notifyListeners();

    try {
      // 1) Crear el usuario en Firebase Auth (valida que el email no exista)
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: contrasena,
      );

      // 2) Si Firebase lo creó, guardamos los datos personales en SQLite local
      final nuevoUsuario = Usuario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombreApellido: nombreApellido.trim(),
        usuario: usuario.trim(),
        dni: dni.trim(),
        email: email.trim(),
        contrasena: contrasena,
        pais: pais.trim(),
        ciudad: ciudad.trim(),
        departamento: departamento.trim(),
      );

      await _servicio.guardar(nuevoUsuario);
      _registrado = true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorEmail = 'Ese email ya está registrado';
      } else if (e.code == 'weak-password') {
        _errorContrasena = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        _errorEmail = 'Email inválido';
      } else {
        _errorGeneral = 'Error al registrar el usuario';
      }
    } catch (_) {
      _errorGeneral = 'Error al registrar el usuario';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}