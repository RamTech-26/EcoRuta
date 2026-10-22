# Informe de Pruebas de Integración — Módulo de Login (EcoRuta)

## 1. Objetivo
El presente informe documenta la implementación y ejecución de las pruebas de Integración para el flujo de **Inicio de Sesión** del proyecto EcoRuta. El objetivo principal es validar la correcta comunicación y el paso de datos entre las distintas capas de la arquitectura: la Vista, el ViewModel y el Repositorio real, aislando únicamente las dependencias externas (los servicios de Firebase).

## 2. Alcance
Esta fase se centra en comprobar que las piezas reales encajan entre sí. A diferencia de las pruebas unitarias o de widget, aquí no se usa un `FakeAuthRepositorio` (que finge ser todo el repositorio), sino que se instancia el **`AuthRepositorio` real** y se le inyectan **Servicios Falsos** (`FakeAuthServicio` y `FakeUsuarioServicio`) que simulan las respuestas de la nube.

## 3. Metodología y Herramientas
- **Framework:** `flutter_test` y `WidgetTester`.
- **Inyección de dependencias:** Uso de `provider` para suministrar el repositorio a la vista.
- **Test Doubles:** Creación de `FakeAuthServicio` (simula las respuestas de Firebase Auth) y `FakeUserCredential` (simula el objeto complejo que devuelve Firebase) para evitar conexiones reales a internet.

## 4. Casos de Prueba Implementados

### 4.1. Prueba de Integración de Lógica (ViewModel + Repositorio)
- **Acción:** Se instancia el `LoginViewModel` con el `AuthRepositorio` real y se ejecuta el método `login()`.
- **Validación:** Se verifica que el ViewModel actualice su estado a `logueado = true` cuando las credenciales son válidas, y que capture correctamente los errores (mapeados por el repositorio) cuando las credenciales son incorrectas.
- **Solución técnica aplicada:** Firebase devuelve un objeto de tipo `UserCredential` que no puede ser instanciado manualmente (tiene constructor privado). Para que la prueba no fallara por incompatibilidad de tipos, se creó una clase `FakeUserCredential` implementando la interfaz original mediante `noSuchMethod` para evadir los métodos no utilizados.

### 4.2. Prueba de Integración de Flujo Completo (Vista + Navegación)
- **Acción:** Se monta la `PantallaLogin` real, se ingresa usuario y contraseña a través de los campos de texto, y se presiona el botón "INICIAR SESIÓN".
- **Validación:** Se comprueba que, al ser exitoso el login a través de todas las capas, la aplicación navegue automáticamente a la `PantallaPrincipal`. El test finaliza verificando que el widget `PantallaPrincipal` se encuentre efectivamente en el árbol de widgets.

## 5. Resultados y Conclusiones
Las pruebas de integración finalizaron de forma exitosa.

**Beneficios obtenidos:**
1. **Validación de la Regla de Negocio:** Se comprobó que la lógica de negocio del `LoginViewModel` y la traducción de errores (mapeo de Firebase a español) realizada por el `AuthRepositorio` funcionan en conjunto.
2. **Navegación asegurada:** Se garantiza que un usuario no se quedará atascado en la pantalla de Login si sus credenciales son correctas; el flujo hacia la pantalla principal es automático y seguro.
3. **Fidelidad del entorno:** Al usar el repositorio real con servicios falsos, estamos probando exactamente el mismo código que se ejecutará en producción, reduciendo la brecha entre el entorno de pruebas y la realidad.
