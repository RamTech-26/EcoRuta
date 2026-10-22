import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecoruta_2026/vistas/pantalla_login.dart';
import 'package:ecoruta_2026/repositorios/auth_repositorio.dart';

import '../fakes.dart';

void main() {
  group('PantallaLogin Widget Tests', () {
    late FakeAuthRepositorio fakeRepositorio;

    setUp(() {
      fakeRepositorio = FakeAuthRepositorio();
      // Evitamos que GoogleFonts intente descargar fuentes en el entorno de pruebas
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    // Función auxiliar para montar la pantalla con el Provider
    Widget crearPantalla() {
      return MaterialApp(
        home: Provider<AuthRepositorio>.value(
          value: fakeRepositorio,
          child: const PantallaLogin(),
        ),
      );
    }

    testWidgets('Debe renderizar los campos y botones principales', (
      tester,
    ) async {
      await tester.pumpWidget(crearPantalla());
      await tester.pump();

      // Verificamos que existan los TextField
      expect(find.byType(TextField), findsNWidgets(2));

      // Verificamos que existan los botones
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(
        find.textContaining('Registrate', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets(
      'Debe mostrar el indicador de carga al presionar Iniciar Sesión',
      (tester) async {
        await tester.pumpWidget(crearPantalla());
        await tester.pump();

        // Escribimos en los campos
        await tester.enterText(find.byType(TextField).first, 'test@test.com');
        await tester.enterText(find.byType(TextField).last, '123456');

        // Tocamos el botón de Iniciar Sesión
        await tester.tap(find.text('INICIAR SESIÓN'));

        // Esperamos un frame para que se dibuje el estado "cargando"
        await tester.pump();

        // Verificamos que aparezca el CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Verificamos que el texto del botón desapareció
        expect(find.text('INICIAR SESIÓN'), findsNothing);
        // Dejamos que pase el tiempo del retraso del Fake para no dejar timers colgados
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Debe mostrar el mensaje de error si el login falla', (
      tester,
    ) async {
      // Configuramos el fake para que falle
      fakeRepositorio.debeFallarLogin = true;
      fakeRepositorio.mensajeError = 'Error de prueba';

      await tester.pumpWidget(crearPantalla());
      await tester.pump();

      // Escribimos e intentamos loguearnos
      await tester.enterText(find.byType(TextField).first, 'test@test.com');
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.tap(find.text('INICIAR SESIÓN'));

      // Esperamos a que termine la animación de carga y se muestre el error
      await tester.pumpAndSettle();

      // Verificamos que el mensaje de error esté en pantalla y en rojo
      expect(find.text('Error de prueba'), findsOneWidget);
    });
  });
}
