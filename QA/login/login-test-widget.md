# Informe de Pruebas de Widget — Módulo de Login (EcoRuta)

## 1. Objetivo
El presente informe detalla la implementación y ejecución de las pruebas de Widget (Pruebas de Interfaz Gráfica) correspondientes a la pantalla de **Inicio de Sesión** del proyecto EcoRuta. El objetivo principal es validar que la Vista renderice correctamente los componentes visuales y que reaccione adecuadamente a los estados emitidos por su respectivo ViewModel (cargando, éxito, error).

## 2. Alcance
Esta fase se limita exclusivamente a la capa de **Vista** (`PantallaLogin`). Las pruebas simulan la interacción de un usuario real (escribir en campos de texto, tocar botones) y validan los cambios en el árbol de widgets de Flutter, sin depender de conexiones reales a internet ni de la base de datos.

## 3. Metodología y Herramientas
Siguiendo la Pirámide de Testing, se escaló desde las pruebas unitarias hacia las pruebas de Widget.
- **Framework:** `flutter_test` y `WidgetTester`.
- **Inyección de dependencias:** Se utilizó el paquete `provider` para inyectar el `FakeAuthRepositorio` en la pantalla, permitiendo simular el entorno sin tocar Firebase.
- **Manejo de asincronía:** Se agregó un retardo simulado (`Future.delayed`) en el Fake y se utilizaron los métodos `tester.pump()` y `tester.pumpAndSettle()` para avanzar en el tiempo de las animaciones y procesos de Flutter.

## 4. Casos de Prueba Implementados

Se desarrollaron 3 pruebas de Widget principales para garantizar el correcto funcionamiento de la interfaz:

### 4.1. Renderizado Inicial de la Pantalla
- **Acción:** Se monta el widget `PantallaLogin` en el entorno de pruebas.
- **Validación:** Se comprueba que existan exactamente 2 `TextField` (email y contraseña) y que estén visibles los textos correspondientes a los botones de "INICIAR SESIÓN", "Continuar con Google" y el enlace de "Registrate".
- **Solución técnica aplicada:** Dado que el enlace de registro está contenido dentro de un widget `RichText` (para manejar colores distintos en una misma línea), fue necesario utilizar el buscador con la directiva `findRichText: true` para que Flutter pudiera encontrarlo en el árbol de widgets.

### 4.2. Transición al Estado de Carga
- **Acción:** Se ingresan credenciales ficticias, se presiona el botón de "INICIAR SESIÓN" y se avanza un frame de animación.
- **Validación:** Se verifica que el texto del botón desaparezca y sea reemplazado por un `CircularProgressIndicator` (indicador de carga), demostrando que la interfaz responde al estado `cargando` del ViewModel.
- **Solución técnica aplicada:** Se incorporó `await tester.pumpAndSettle()` al final del test. Esto es crucial para esperar a que finalicen los temporizadores (timers) simulados de la red, evitando que las pruebas fallen por dejar procesos asíncronos "colgados".

### 4.3. Visualización de Errores
- **Acción:** Se configuró el Fake para que lance un error de credenciales y se presionó el botón de inicio de sesión.
- **Validación:** Se verifica que el texto con el mensaje de error ("Error de prueba") aparezca en pantalla, asegurando que el usuario reciba feedback visual ante un fallo en el inicio de sesión.

## 5. Resultados y Conclusiones
La totalidad de las pruebas de Widget (3 en total) se ejecutaron de forma exitosa (3/3).

**Beneficios obtenidos:**
1. **Validación de la Experiencia de Usuario (UX):** Se garantiza que los elementos clave de la pantalla se dibujan correctamente en distintos escenarios.
2. **Reactividad comprobada:** Se verificó empíricamente que el uso de `ListenableBuilder` y `ChangeNotifier` funciona; la interfaz se actualiza en tiempo real cuando el ViewModel cambia de estado.
3. **Robustez en el código:** La detección y solución de problemas (como la búsqueda en textos enriquecidos y la gestión de tiempos de espera asíncronos) dejó un código de test más maduro y a prueba de futuros cambios visuales.

