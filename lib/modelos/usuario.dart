/// Modelo de usuario registrado en la app.
///
/// Guarda los datos personales y de ubicación. La contraseña no se guarda:
/// la verifica Firebase Auth y no tiene que quedar en el celular.
class Usuario {
  final String id; // uid de Firebase
  final String nombreApellido; // nombre y apellido del usuario
  final String usuario; // nombre de usuario
  final String dni; // documento de identidad
  final String email; // correo electrónico
  final String pais; // país de residencia
  final String ciudad; // ciudad de residencia
  final String departamento; // departamento o localidad

  Usuario({
    required this.id,
    required this.nombreApellido,
    required this.usuario,
    required this.dni,
    required this.email,
    required this.pais,
    required this.ciudad,
    required this.departamento,
  });

  /// Convierte el usuario a un mapa para guardarlo en la base de datos.
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombreApellido': nombreApellido,
    'usuario': usuario,
    'dni': dni,
    'email': email,
    'pais': pais,
    'ciudad': ciudad,
    'departamento': departamento,
  };

  /// Reconstruye un usuario a partir de un mapa leído de la base de datos.
  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'] as String,
    nombreApellido: map['nombreApellido'] as String,
    usuario: map['usuario'] as String,
    dni: map['dni'] as String,
    email: map['email'] as String,
    pais: map['pais'] as String,
    ciudad: map['ciudad'] as String,
    departamento: map['departamento'] as String,
  );

  /// Devuelve una copia del usuario con los campos que se pasen modificados.
  Usuario copyWith({
    String? id,
    String? nombreApellido,
    String? usuario,
    String? dni,
    String? email,
    String? pais,
    String? ciudad,
    String? departamento,
  }) => Usuario(
    id: id ?? this.id,
    nombreApellido: nombreApellido ?? this.nombreApellido,
    usuario: usuario ?? this.usuario,
    dni: dni ?? this.dni,
    email: email ?? this.email,
    pais: pais ?? this.pais,
    ciudad: ciudad ?? this.ciudad,
    departamento: departamento ?? this.departamento,
  );
}
