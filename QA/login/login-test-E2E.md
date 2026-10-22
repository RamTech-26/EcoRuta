# Informe de Pruebas E2E (End-to-End) — Módulo de Login (EcoRuta)

## 1. Objetivo
El presente informe documenta la implementación y ejecución exitosa de la prueba de Integración End-to-End (E2E) para el flujo completo de autenticación del proyecto EcoRuta. El objetivo principal es validar la aplicación de manera holística, simulando el comportamiento exacto de un usuario real (toques, escritura, navegación y validaciones) en un entorno controlado.

## 2. Alcance
Esta prueba cubre el flujo completo del usuario:
1. Intento fallido de registro (validación de contraseñas).
2. Registro exitoso.
3. Inicio de sesión exitoso.
4. Cierre de sesión desde la pantalla principal.
5. Inicio de sesión fallido (usuario incorrecto).
6. Inicio de sesión fallido (contraseña incorrecta).
7. Inicio de sesión mediante Google (simulado).
8. Cierre de sesión final.

## 3. Metodología y Herramientas
- **Framework:** `integration_test` (paquete oficial de Flutter para pruebas E2E).
- **Entorno:** Dispositivo físico/emulador Android ejecutando la aplicación real compilada (APK).
- **Manejo de dependencias:** Uso de `provider` para inyectar el `AuthRepositorio` (con servicios falsos) en toda la app.
- **Firebase Core:** Inicialización del entorno real de Firebase para permitir que las llamadas nativas del botón de "Cerrar sesión" no arrojen errores de nulidad.

## 4. Desafíos Técnicos y Soluciones Implementadas

Durante la implementación de la prueba, surgieron varios desafíos técnicos propios de la interacción entre el entorno de pruebas y Flutter:

### 4.1. Alcance del Provider en la Navegación
- **Problema:** Al navegar a la pantalla de Registro con `Navigator.push`, el widget se construía por fuera del `Provider`, arrojando `ProviderNotFoundException`.
- **Solución:** Se movió el `Provider<AuthRepositorio>` para que envuelva a todo el `MaterialApp`, garantizando que todas las rutas tengan acceso al repositorio.

### 4.2. Asincronía y Temporizadores en el Registro
- **Problema:** El comando `pumpAndSettle` de Flutter no espera a que terminen los futuros asíncronos reales (como el guardado del registro). El test avanzaba antes de que la UI se actualizara.
- **Solución:** Se creó una función de *polling* (`esperarWidget`) que consulta constantemente durante un tiempo límite si el widget esperado ya se dibujó en pantalla.

### 4.3. Interacción con el Teclado Virtual
- **Problema:** El teclado virtual de Android permanecía abierto tras el login, reduciendo el tamaño del viewport y evitando que el panel inferior (DraggableScrollableSheet) se expandiera correctamente, ocultando el botón "Cerrar sesión".
- **Solución:** Se implementó la función `ocultarTeclado`, que utiliza `SystemChannels.textInput` para forzar el cierre del teclado nativo antes de interactuar con el panel.

### 4.4. El Gesto del Panel Deslizable (Snap)
- **Problema:** Al intentar deslizar el `DraggableScrollableSheet`, el toque caía sobre el mapa, o al usar `ensureVisible` el panel se volvía a cerrar por su comportamiento de "snap".
- **Solución:** Se identificó el widget `Scrollable` interno del panel para usar `tester.fling`. Además, se reemplazó el `ensureVisible` por tiempos de espera explícitos (`tester.pump`) para permitir que el panel se asiente en su posición máxima y el botón sea clickeable.

### 4.5. Dependencia de Firebase sin Inicializar
- **Problema:** La `PantallaPrincipal` de producción ejecuta `FirebaseAuth.instance.signOut()` directamente. En el entorno de pruebas, Firebase no estaba inicializado, causando un crash.
- **Solución:** Se agregó un `setUpAll` en el archivo de test para inicializar `Firebase.apps` antes de ejecutar la prueba, permitiendo que el código de producción real corra sin fallar, mientras el inicio de sesión sigue usando los servicios falsos (Fakes).

## 5. Resultados y Conclusiones
La totalidad de la prueba E2E se ejecutó de forma exitosa (100% verde).

**Beneficios obtenidos:**
1. **Validación de Experiencia de Usuario (UX):** Se comprobó que el usuario puede completar todo el ciclo de autenticación sin bloqueos.
2. **Robustez del sistema:** Los mecanismos de validación en el registro (contraseñas) y en el login (credenciales) funcionan y muestran los errores correctamente en pantalla.
3. **Integración de capas reales:** Se validó que el flujo desde la interfaz de usuario (View), pasando por la lógica (ViewModel), hasta el almacenamiento (Repository), se comunican de manera perfecta en un entorno real.
4. **Preparación para la EGI:** El test provee una herramienta visual e interactiva que demuestra de forma automatizada el correcto funcionamiento de uno de los módulos más críticos del sistema.