import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:ecoruta_2026/repositorios/auth_repositorio.dart';
import 'package:ecoruta_2026/vistas/pantalla_login.dart';
import 'package:ecoruta_2026/vistas/pantalla_principal.dart';
import 'package:firebase_core/firebase_core.dart';

// Importamos los fakes que creaste en la carpeta test
import '../test/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  group('Flujo E2E Completo - Autenticación', () {
    late FakeAuthServicio fakeAuthServicio;
    late FakeUsuarioServicio fakeUsuarioServicio;
    late AuthRepositorio authRepositorio;

    setUp(() {
      // 1. Preparamos los servicios falsos para el test
      fakeAuthServicio = FakeAuthServicio();
      fakeUsuarioServicio = FakeUsuarioServicio();
      authRepositorio = AuthRepositorio(
        authServicio: fakeAuthServicio,
        usuarioServicio: fakeUsuarioServicio,
      );
    });

    testWidgets('Prueba completa de Registro, Login, Errores y Google', (
      tester,
    ) async {
      // 2. Arrancamos la app inyectando el Repositorio
      await tester.pumpWidget(
        Provider<AuthRepositorio>.value(
          value: authRepositorio,
          child: const MaterialApp(home: PantallaLogin()),
        ),
      );
      await tester.pumpAndSettle();

      // ==========================================
      // PASO 1: IR A REGISTRO Y PROBAR ERROR
      // ==========================================
      await tester.tap(find.textContaining('Registrate', findRichText: true));
      await tester.pumpAndSettle();

      // Llenamos los campos
      await tester.enterText(
        find.widgetWithText(TextField, 'Nombre y apellido'),
        'Matias Test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Usuario'),
        'matias',
      );
      await tester.enterText(find.widgetWithText(TextField, 'DNI'), '12345678');
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'matias@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        '123456',
      );
      // A propósito ponemos mal la contraseña repetida
      await tester.enterText(
        find.widgetWithText(TextField, 'Repetir contraseña'),
        '12345',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'País'),
        'Argentina',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Ciudad'),
        'Mendoza',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Departamento'),
        'Godoy Cruz',
      );

      // Tocamos Registrar
      await tester.tap(find.text('REGISTRAR'));
      await tester.pumpAndSettle();

      // Verificamos que aparezca el error de contraseñas
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

      // ==========================================
      // PASO 2: REGISTRO EXITOSO
      // ==========================================
      // Corregimos la contraseña
      await tester.enterText(
        find.widgetWithText(TextField, 'Repetir contraseña'),
        '123456',
      );
      await tester.tap(find.text('REGISTRAR'));
      await tester.pumpAndSettle();

      // Confirmamos en el diálogo
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Esperamos a que termine el registro asíncrono y vuelva al Login
      final volvioAlLogin = await esperarWidget(
        tester,
        find.text('INICIAR SESIÓN'),
      );
      if (!volvioAlLogin) {
        volcarTextos(); // Muestra qué textos hay en pantalla si falla
      }

      // Debería volver al Login
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);

      // ==========================================
      // PASO 3: LOGIN EXITOSO
      // ==========================================
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'matias@test.com',
      );
            await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        '123456',
      );
      await ocultarTeclado(tester);
      await tester.tap(find.text('INICIAR SESIÓN'));
      await tester.pumpAndSettle();

      // Verificamos que entramos a la PantallaPrincipal
      expect(find.byType(PantallaPrincipal), findsOneWidget);

      // Esperamos un rato a que la pantalla y el teclado se estabilicen
      await tester.pump(const Duration(seconds: 4));

      // ==========================================
      // PASO 4: CERRAR SESIÓN
      // ==========================================
      await cerrarSesionDesdePanel(tester);

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);

      // ==========================================
      // PASO 5: LOGIN FALLIDO (MAL USUARIO)
      // ==========================================
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'pepe@test.com',
      ); // Mal email
      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        '123456',
      );
      await ocultarTeclado(tester);
      await tester.tap(find.text('INICIAR SESIÓN'));
      await tester.pumpAndSettle();

      // Asumimos que el Fake está configurado para fallar si no es "matias@test.com"
      expect(find.byType(PantallaLogin), findsOneWidget);

      // ==========================================
      // PASO 6: LOGIN FALLIDO (MAL CONTRASEÑA)
      // ==========================================
      // NOTA: Para simular este paso, le decimos al Fake que falle la próxima
      fakeAuthServicio.debeFallarLogin = true;

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'matias@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        'clave_mala',
      );
      await ocultarTeclado(tester);
      await tester.tap(find.text('INICIAR SESIÓN'));
      await tester.pumpAndSettle();

      expect(find.text('Contraseña incorrecta'), findsOneWidget);

      // ==========================================
      // PASO 7: LOGIN CON GOOGLE
      // ==========================================
      fakeAuthServicio.debeFallarLogin = false; // Restauramos

      await tester.tap(find.text('Continuar con Google'));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaPrincipal), findsOneWidget);

      // ==========================================
      // PASO 8: CERRAR SESIÓN NUEVAMENTE
      // ==========================================
      await cerrarSesionDesdePanel(tester);

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    });
  });
}

Future<bool> esperarWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final fin = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(fin)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

void volcarTextos() {
  for (final e in find.byType(Text).evaluate()) {
    debugPrint('TEXT: ${(e.widget as Text).data}');
  }
}

Finder _scrollableDelPanel() => find
    .descendant(
      of: find.byType(DraggableScrollableSheet),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axis == Axis.vertical,
      ),
    )
    .first;

Future<void> cerrarSesionDesdePanel(WidgetTester tester) async {
  // Espera antes de hacer el scroll
  await tester.pump(const Duration(seconds: 3));
  await ocultarTeclado(tester);
  await tester.pump(const Duration(seconds: 1));

  // Deslizamos el panel hacia arriba
  await tester.fling(
    _scrollableDelPanel(),
    const Offset(0, -500),
    1000,
    warnIfMissed: false,
  );
  await tester.pump(const Duration(seconds: 2));

  // Esperamos a que aparezca el botón y tocamos
  final boton = find.text('Cerrar sesión');
  final aparecio = await esperarWidget(tester, boton);
  if (!aparecio) volcarTextos();
  expect(boton, findsOneWidget);

  await tester.pump(const Duration(seconds: 1));
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

Future<void> ocultarTeclado(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}
