import 'package:flutter/foundation.dart';

import '../servicios/usuario_servicio.dart';

class LoginViewModel extends ChangeNotifier {
  final UsuarioServicio _servicio = UsuarioServicio();

  bool _logueado = false;
  bool _cargando = false;
  String? _error;

  bool get logueado => _logueado;
  bool get cargando => _cargando;
  String? get error => _error;

  bool _ocultarContrasena = true;
  bool get ocultarContrasena => _ocultarContrasena;

  void alternarVisibilidadContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
  }

  Future<void> login(String nombre, String pass) async {
    if (nombre.trim().isEmpty || pass.trim().isEmpty) {
      _error = 'Completá usuario y contraseña';
      notifyListeners();
      return;
    }
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final usuario = await _servicio.obtenerPorUsuario(nombre.trim());
      if (usuario == null || usuario.contrasena != pass.trim()) {
        _error = 'Usuario o contraseña incorrectos'; 
      } else {
        _logueado = true;
      }
    } catch (_) {
      _error = 'Error al iniciar sesión';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
