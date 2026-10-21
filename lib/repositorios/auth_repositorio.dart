import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/error_auth.dart';
import '../modelos/usuario.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/usuario_servicio.dart';

/// Fuente de verdad de la sesión del usuario.
///
/// Usa [AuthServicio] para hablar con Firebase Auth y [UsuarioServicio]
/// para guardar los datos del usuario en la base local. Los errores de
/// Firebase se traducen a [ErrorAuth].
class AuthRepositorio {
  AuthRepositorio({
    required this._authServicio,
    required this._usuarioServicio,
  });

  final AuthServicio _authServicio;
  final UsuarioServicio _usuarioServicio;

  /// Avisa cada vez que el usuario inicia o cierra sesión.
  Stream<User?> observarSesion() => _authServicio.observarSesion();

  /// Inicia sesión con email y contraseña.
  ///
  /// Lanza [ErrorAuth] si Firebase rechaza los datos.
  Future<void> iniciarSesion(String email, String password) async {
    try {
      await _authServicio.login(email, password);
    } on FirebaseAuthException catch (e) {
      throw ErrorAuth(_tipoDeError(e.code));
    }
  }

  /// Inicia sesión con Google y guarda el usuario en la base local.
  ///
  /// Google no da DNI, país ni ciudad: esos campos quedan vacíos.
  /// Si el usuario cierra el selector de cuentas, lanza [ErrorAuth] con
  /// [TipoErrorAuth.canceladoPorUsuario].
  Future<void> iniciarConGoogle() async {
    try {
      final cred = await _authServicio.loginConGoogle();
      if (cred == null) {
        throw const ErrorAuth(TipoErrorAuth.canceladoPorUsuario);
      }
      final user = cred.user;
      if (user == null) return;
      await _usuarioServicio.guardar(
        Usuario(
          id: user.uid,
          nombreApellido: user.displayName ?? '',
          usuario: user.email?.split('@').first ?? user.uid,
          dni: '',
          email: user.email ?? '',
          pais: '',
          ciudad: '',
          departamento: '',
        ),
      );
    } on ErrorAuth {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw ErrorAuth(_tipoDeError(e.code));
    } on Exception {
      // Errores del plugin de Google: sin conexión, SHA-1 no cargado, etc.
      throw const ErrorAuth(TipoErrorAuth.desconocido);
    }
  }

  /// Crea la cuenta en Firebase y guarda el usuario en la base local,
  /// usando el uid de Firebase como id.
  ///
  /// Lanza [ErrorAuth] si Firebase rechaza el registro.
  Future<void> registrar(Usuario usuario, String password) async {
    try {
      final cred = await _authServicio.registrar(usuario.email, password);
      final user = cred.user;
      if (user == null) throw const ErrorAuth(TipoErrorAuth.desconocido);
      await _usuarioServicio.guardar(usuario.copyWith(id: user.uid));
    } on ErrorAuth {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw ErrorAuth(_tipoDeError(e.code));
    }
  }

  /// Cierra la sesión de Firebase y de Google.
  Future<void> cerrarSesion() => _authServicio.logout();

  /// Traduce el código de Firebase al tipo de error de la app.
  ///
  /// Con la protección contra enumeración de emails (activa por defecto
  /// en los proyectos nuevos), Firebase devuelve `invalid-credential` en
  /// vez de `user-not-found` o `wrong-password`: por eso los tres van
  /// al mismo tipo.
  TipoErrorAuth _tipoDeError(String codigo) => switch (codigo) {
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => TipoErrorAuth.credencialesInvalidas,
    'email-already-in-use' => TipoErrorAuth.emailEnUso,
    'invalid-email' => TipoErrorAuth.emailInvalido,
    'weak-password' => TipoErrorAuth.contrasenaDebil,
    'network-request-failed' => TipoErrorAuth.sinConexion,
    'too-many-requests' => TipoErrorAuth.demasiadosIntentos,
    _ => TipoErrorAuth.desconocido,
  };
}
