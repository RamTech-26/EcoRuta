import 'package:flutter_test/flutter_test.dart';
import 'package:ecoruta_2026/modelos/usuario.dart';

void main() {
  // Agrupamos las pruebas del modelo Usuario
  group('Usuario Model', () {
    
    // Creamos un usuario de prueba para usar en todos los tests
    final usuarioPrueba = Usuario(
      id: '123',
      nombreApellido: 'Matias Fernandez',
      usuario: 'matifer',
      dni: '12345678',
      email: 'matias@test.com',
      contrasena: 'miClave123',
      pais: 'Argentina',
      ciudad: 'Mendoza',
      departamento: 'Godoy Cruz',
    );

    test('toMap() debe convertir un Usuario a un Map correctamente', () {
      // Ejecutamos el método
      final map = usuarioPrueba.toMap();

      // Verificamos que los campos coincidan
      expect(map['id'], '123');
      expect(map['nombreApellido'], 'Matias Fernandez');
      expect(map['usuario'], 'matifer');
      expect(map['dni'], '12345678');
      expect(map['email'], 'matias@test.com');
      expect(map['contrasena'], 'miClave123');
      expect(map['pais'], 'Argentina');
      expect(map['ciudad'], 'Mendoza');
      expect(map['departamento'], 'Godoy Cruz');
    });

    test('fromMap() debe reconstruir un Usuario desde un Map correctamente', () {
      // Creamos un mapa falso (simulando lo que viene de la base de datos)
      final map = {
        'id': '456',
        'nombreApellido': 'Ana Gomez',
        'usuario': 'anag',
        'dni': '87654321',
        'email': 'ana@test.com',
        'contrasena': 'otraClave',
        'pais': 'Argentina',
        'ciudad': 'Mendoza',
        'departamento': 'Capital',
      };

      // Reconstruimos el objeto
      final usuarioReconstruido = Usuario.fromMap(map);

      // Verificamos que los datos se hayan pasado bien
      expect(usuarioReconstruido.id, '456');
      expect(usuarioReconstruido.nombreApellido, 'Ana Gomez');
      expect(usuarioReconstruido.usuario, 'anag');
      expect(usuarioReconstruido.dni, '87654321');
      expect(usuarioReconstruido.email, 'ana@test.com');
      expect(usuarioReconstruido.contrasena, 'otraClave');
      expect(usuarioReconstruido.pais, 'Argentina');
      expect(usuarioReconstruido.ciudad, 'Mendoza');
      expect(usuarioReconstruido.departamento, 'Capital');
    });

    test('copyWith() debe cambiar solo el campo especificado', () {
      // Copiamos el usuario original cambiando solo el email
      final usuarioModificado = usuarioPrueba.copyWith(email: 'nuevo@test.com');

      // El email debe haber cambiado
      expect(usuarioModificado.email, 'nuevo@test.com');
      
      // Los demás campos deben seguir iguales
      expect(usuarioModificado.id, '123');
      expect(usuarioModificado.nombreApellido, 'Matias Fernandez');
      expect(usuarioModificado.usuario, 'matifer');
      expect(usuarioModificado.contrasena, 'miClave123');
    });
  });
}