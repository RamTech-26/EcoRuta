import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/usuario.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/usuario_servicio.dart';

class AuthRepositorio {
  final AuthServicio _authServicio;
  final UsuarioServicio _usuarioServicio;

  AuthRepositorio({
    required this._authServicio,
    required this._usuarioServicio,
  });

  Stream<User?> observarSesion() => _authServicio.observarSesion();

  Future<void> iniciarSesion(String email, String password) async {
    try {
      await _authServicio.login(email, password);
    } on FirebaseAuthException catch (e) {
      throw _mapearError(e);
    }
  }

  Future<void> iniciarConGoogle() async {
    try {
      final cred = await _authServicio.loginConGoogle();
      if (cred.user != null) {
        // Google no da dni, pais, etc. Guardamos con placeholders
        final u = Usuario(
          id: cred.user!.uid,
          nombreApellido: cred.user!.displayName ?? '',
          usuario: cred.user!.email?.split('@').first ?? cred.user!.uid,
          dni: '',
          email: cred.user!.email ?? '',
          contrasena: '',
          pais: '',
          ciudad: '',
          departamento: '',
        );
        await _usuarioServicio.guardar(u);
      }
    } on FirebaseAuthException catch (e) {
      throw _mapearError(e);
    }
  }

  Future<void> registrar(Usuario usuario, String password) async {
    try {
      final cred = await _authServicio.registrar(usuario.email, password);
      final conId = usuario.copyWith(id: cred.user!.uid);
      await _usuarioServicio.guardar(conId);
    } on FirebaseAuthException catch (e) {
      throw _mapearError(e);
    }
  }

  Future<void> cerrarSesion() => _authServicio.logout();

  String _mapearError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }
}
