/// Tipos de error de autenticación que la app sabe mostrar.
enum TipoErrorAuth {
  credencialesInvalidas('Email o contraseña incorrectos'),
  emailEnUso('El email ya está registrado'),
  emailInvalido('Email inválido'),
  contrasenaDebil('La contraseña es muy débil'),
  sinConexion('Sin conexión. Revisá internet y probá de nuevo'),
  demasiadosIntentos('Demasiados intentos. Esperá unos minutos'),
  canceladoPorUsuario('Inicio de sesión cancelado'),
  desconocido('No se pudo completar la operación. Probá de nuevo');

  const TipoErrorAuth(this.mensaje);

  /// Texto en español que ve el usuario.
  final String mensaje;
}

/// Error de autenticación ya traducido para la app.
///
/// Lo lanza `AuthRepositorio`, así los ViewModels deciden qué mostrar
/// según el [tipo] sin depender de los códigos de Firebase.
class ErrorAuth implements Exception {
  const ErrorAuth(this.tipo);

  final TipoErrorAuth tipo;

  /// Texto en español que ve el usuario.
  String get mensaje => tipo.mensaje;

  @override
  String toString() => mensaje;
}
