import 'package:ecoruta_2026/modelos/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Usuario Model', () {
    final usuarioPrueba = Usuario(
      id: '123',
      nombreApellido: 'Matias Fernandez',
      usuario: 'matifer',
      dni: '12345678',
      email: 'matias@test.com',
      pais: 'Argentina',
      ciudad: 'Mendoza',
      departamento: 'Godoy Cruz',
    );

    test('toMap() debe convertir un Usuario a un Map correctamente', () {
      final map = usuarioPrueba.toMap();

      expect(map['id'], '123');
      expect(map['nombreApellido'], 'Matias Fernandez');
      expect(map['usuario'], 'matifer');
      expect(map['dni'], '12345678');
      expect(map['email'], 'matias@test.com');
      expect(map['pais'], 'Argentina');
      expect(map['ciudad'], 'Mendoza');
      expect(map['departamento'], 'Godoy Cruz');
    });

    test(
      'fromMap() debe reconstruir un Usuario desde un Map correctamente',
      () {
        final map = {
          'id': '456',
          'nombreApellido': 'Ana Gomez',
          'usuario': 'anag',
          'dni': '87654321',
          'email': 'ana@test.com',
          'pais': 'Argentina',
          'ciudad': 'Mendoza',
          'departamento': 'Capital',
        };

        final usuarioReconstruido = Usuario.fromMap(map);

        expect(usuarioReconstruido.id, '456');
        expect(usuarioReconstruido.nombreApellido, 'Ana Gomez');
        expect(usuarioReconstruido.usuario, 'anag');
        expect(usuarioReconstruido.dni, '87654321');
        expect(usuarioReconstruido.email, 'ana@test.com');
        expect(usuarioReconstruido.pais, 'Argentina');
        expect(usuarioReconstruido.ciudad, 'Mendoza');
        expect(usuarioReconstruido.departamento, 'Capital');
      },
    );

    test('copyWith() debe cambiar solo el campo especificado', () {
      final usuarioModificado = usuarioPrueba.copyWith(email: 'nuevo@test.com');

      expect(usuarioModificado.email, 'nuevo@test.com');

      expect(usuarioModificado.id, '123');
      expect(usuarioModificado.nombreApellido, 'Matias Fernandez');
      expect(usuarioModificado.usuario, 'matifer');
    });
  });
}
