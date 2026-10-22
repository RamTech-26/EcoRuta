import 'package:ecoruta_2026/viewmodels/login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  group('LoginViewModel', () {
    late FakeAuthRepositorio fakeRepositorio;
    late LoginViewModel viewModel;

    // Esto se ejecuta antes de CADA test para tener todo limpio
    setUp(() {
      fakeRepositorio = FakeAuthRepositorio();
      viewModel = LoginViewModel(repositorio: fakeRepositorio);
    });

    test('Debe mostrar error si los campos están vacíos', () async {
      await viewModel.login('', '');

      expect(viewModel.error, 'Completá email y contraseña');
      expect(viewModel.cargando, false);
      expect(viewModel.logueado, false);
    });

    test('Debe loguearse correctamente con credenciales válidas', () async {
      // Ejecutamos el login
      await viewModel.login('test@test.com', '123456');

      // Verificamos que los estados finales sean correctos
      expect(viewModel.error, isNull);
      expect(viewModel.logueado, true);
      expect(
        viewModel.cargando,
        false,
      ); // Debe haber vuelto a false al terminar
    });

    test('Debe mostrar error si las credenciales son incorrectas', () async {
      // Le decimos al fake que falle
      fakeRepositorio.debeFallarLogin = true;

      await viewModel.login('test@test.com', 'error');

      expect(viewModel.error, 'Usuario o contraseña incorrectos');
      expect(viewModel.logueado, false);
      expect(viewModel.cargando, false);
    });

    test('Debe loguearse correctamente con Google', () async {
      await viewModel.loginConGoogle();

      expect(viewModel.error, isNull);
      expect(viewModel.logueado, true);
      expect(viewModel.cargando, false);
    });

    test('Debe mostrar error si falla el login con Google', () async {
      fakeRepositorio.debeFallarGoogle = true;
      fakeRepositorio.mensajeError = 'Login cancelado';

      await viewModel.loginConGoogle();

      expect(viewModel.error, 'Login cancelado');
      expect(viewModel.logueado, false);
      expect(viewModel.cargando, false);
    });
  });
}
