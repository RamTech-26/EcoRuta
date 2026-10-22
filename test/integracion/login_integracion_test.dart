import 'package:ecoruta_2026/repositorios/auth_repositorio.dart';
import 'package:ecoruta_2026/viewmodels/login_viewmodel.dart';
import 'package:ecoruta_2026/vistas/pantalla_login.dart';
import 'package:ecoruta_2026/vistas/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

void main() {
  group('Prueba de Integración: Login', () {
    late FakeAuthServicio fakeAuthServicio;
    late FakeUsuarioServicio fakeUsuarioServicio;
    late AuthRepositorio authRepositorio;

    setUp(() {
      fakeAuthServicio = FakeAuthServicio();
      fakeUsuarioServicio = FakeUsuarioServicio();

      authRepositorio = AuthRepositorio(
        authServicio: fakeAuthServicio,
        usuarioServicio: fakeUsuarioServicio,
      );
    });

    test('Debe loguearse correctamente a través de las capas reales', () async {
      final viewModel = LoginViewModel(repositorio: authRepositorio);
      await viewModel.login('test@test.com', '123456');

      expect(viewModel.logueado, true);
      expect(viewModel.error, isNull);
    });

    testWidgets(
      'Flujo completo: Debe navegar a PantallaPrincipal tras login exitoso',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<AuthRepositorio>.value(
              value: authRepositorio,
              child: const PantallaLogin(),
            ),
          ),
        );
        await tester.pump();

        await tester.enterText(find.byType(TextField).first, 'test@test.com');
        await tester.enterText(find.byType(TextField).last, '123456');

        await tester.tap(find.text('INICIAR SESIÓN'));

        await tester.pumpAndSettle();

        expect(find.byType(PantallaPrincipal), findsOneWidget);
      },
    );
  });
}
