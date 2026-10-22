import 'package:ecoruta_2026/modelos/usuario.dart';
import 'package:ecoruta_2026/repositorios/auth_repositorio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecoruta_2026/servicios/auth_servicio.dart';
import 'package:ecoruta_2026/servicios/usuario_servicio.dart';

/// Fake de AuthRepositorio para usar en los tests.
/// Simula respuestas exitosas o fallidas sin conectarse a Firebase.
class FakeAuthRepositorio implements AuthRepositorio {
  bool debeFallarLogin = false;
  bool debeFallarGoogle = false;
  String mensajeError = 'Usuario o contraseña incorrectos';

  @override
  Future<void> iniciarSesion(String email, String password) async {
    if (debeFallarLogin) {
      throw mensajeError;
    }
    // Simulamos un pequeño retraso de red (100 ms) para capturar el estado de carga
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> iniciarConGoogle() async {
    if (debeFallarGoogle) {
      throw mensajeError;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // --- Métodos obligatorios por la interfaz, pero no los usamos en este test ---

  @override
  Stream<User?> observarSesion() => const Stream.empty();

  @override
  Future<void> registrar(Usuario usuario, String password) async {}

  @override
  Future<void> cerrarSesion() async {}
}

class FakeAuthServicio implements AuthServicio {
  bool debeFallarLogin = false;

  @override
  Future<UserCredential> login(String email, String password) async {
    // Si le decimos que falle o si el email no es el correcto, tiramos error
    if (debeFallarLogin || email != 'matias@test.com') {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Contraseña incorrecta',
      );
    }
    return FakeUserCredential();
  }

  @override
  Stream<User?> observarSesion() => const Stream.empty();

  @override
  User? get usuarioActual => null;

  @override
  Future<UserCredential> loginConGoogle() async {
    return FakeUserCredential();
  }

  @override
  Future<UserCredential> registrar(String email, String password) async {
    return FakeUserCredential();
  }

  @override
  Future<void> logout() async {}
}

class FakeUsuarioServicio implements UsuarioServicio {
  @override
  Future<void> guardar(Usuario usuario) async {}

  @override
  Future<Usuario?> obtenerPorUsuario(String usuario) async => null;

  @override
  Future<bool> existeUsuario(String usuario) async => false;
}

// Clase falsa para simular el usuario de Firebase
class FakeUser implements User {
  @override
  String get uid => 'fake_uid_123';
  @override
  String? get email => 'test@test.com';
  @override
  String? get displayName => 'Test User';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Clase falsa para simular el UserCredential de Firebase
class FakeUserCredential implements UserCredential {
  @override
  User get user => FakeUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
