import 'package:flutter/foundation.dart';

import '../modelos/error_auth.dart';
import '../repositorios/auth_repositorio.dart';

/// ViewModel de la pantalla de login.
///
/// Inicia sesión con email o con Google y expone el estado de carga
/// y el mensaje de error que muestra la vista.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._repositorio});

  final AuthRepositorio _repositorio;

  bool _logueado = false;
  bool _cargando = false;
  String? _error;
  bool _ocultarContrasena = true;

  bool get logueado => _logueado;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get ocultarContrasena => _ocultarContrasena;

  void alternarVisibilidadContrasena() {
    _ocultarContrasena = !_ocultarContrasena;
    notifyListeners();
  }

  /// Inicia sesión con email y contraseña.
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
    } on ErrorAuth catch (e) {
      _error = e.mensaje;
    } catch (_) {
      _error = TipoErrorAuth.desconocido.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Inicia sesión con Google.
  ///
  /// Si el usuario cierra el selector de cuentas no se muestra ningún
  /// error: decidió no entrar.
  Future<void> loginConGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _repositorio.iniciarConGoogle();
      _logueado = true;
    } on ErrorAuth catch (e) {
      if (e.tipo != TipoErrorAuth.canceladoPorUsuario) _error = e.mensaje;
    } catch (_) {
      _error = TipoErrorAuth.desconocido.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}