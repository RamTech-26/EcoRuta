import 'package:flutter/foundation.dart';

import '../repositorios/auth_repositorio.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepositorio _repositorio;
  LoginViewModel({required this._repositorio});

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

  Future<void> login(String email, String pass) async {
    if (email.trim().isEmpty || pass.trim().isEmpty) {
      _error = 'Completá email y contraseña';
      notifyListeners();
      return;
    }
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _repositorio.iniciarSesion(email, pass);
      _logueado = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> loginConGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _repositorio.iniciarConGoogle();
      _logueado = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
