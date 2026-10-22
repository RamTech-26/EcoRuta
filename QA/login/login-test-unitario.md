# Informe de Pruebas Unitarias — Módulo de Login (EcoRuta)

## 1. Objetivo
El presente informe detalla la implementación y ejecución de las pruebas unitarias correspondientes a la funcionalidad de **Inicio de Sesión** del proyecto EcoRuta. El objetivo principal es garantizar la robustez de la lógica de negocio y la correcta manipulación de los datos de usuario, aislando el sistema de dependencias externas como Firebase o bases de datos locales.

## 2. Alcance
Esta fase de pruebas se limita exclusivamente a la capa de **Modelo** y **ViewModel** del módulo de autenticación. No incluye pruebas visuales (Widgets) ni flujos de extremo a extremo (E2E), los cuales se abordarán en etapas posteriores.

## 3. Metodología y Herramientas
Siguiendo la Pirámide de Testing, se optó por pruebas de la base (Unitarias). Para garantizar la velocidad y el aislamiento:
- **Framework:** `flutter_test`.
- **Patrón de diseño:** Uso de *Fakes* (Test Doubles) mediante un archivo centralizado (`fakes.dart`).
- **Aislamiento:** Se simuló el comportamiento del repositorio (`FakeAuthRepositorio`) para evitar realizar peticiones reales a los servidores de Firebase durante las pruebas.

## 4. Casos de Prueba Implementados

### 4.1. Modelo `Usuario` (Capa de Datos)
Se validó que la entidad principal de usuario se comporte correctamente al interactuar con la base de datos.

- **`toMap()`:** Verifica que un objeto `Usuario` se serialice correctamente en un `Map<String, dynamic>` con las claves exactas esperadas por SQLite.
- **`fromMap()`:** Asegura que un mapa proveniente de la base de datos reconstruya un objeto `Usuario` sin pérdida de información ni errores de casteo.
- **`copyWith()`:** Comprueba la inmutabilidad del modelo, verificando que al generar una copia modificando un campo específico (ej. email), el resto de los atributos originales se mantengan intactos.

### 4.2. ViewModel `LoginViewModel` (Capa de Lógica de Presentación)
Se evaluó el comportamiento del estado (`ChangeNotifier`) y la comunicación con el repositorio de autenticación.

- **Validación de campos vacíos:** Comprueba que el ViewModel detenga la ejecución, actualice el estado de `error` y no intente comunicarse con el repositorio si el usuario o la contraseña están vacíos.
- **Login exitoso (Email/Contraseña):** Verifica que, con credenciales válidas, el estado `logueado` cambie a `true`, el estado de `cargando` retorne a `false` y el error se limpie.
- **Login fallido (Email/Contraseña):** Simula una excepción desde el repositorio (ej. credenciales incorrectas). Asegura que el ViewModel capture el error, lo exponga en la UI mediante el estado `error` y mantenga `logueado` en `false`.
- **Login exitoso con Google:** Valida el flujo alternativo de autenticación, asegurando que el estado de éxito se active correctamente.
- **Login fallido con Google:** Simula la cancelación o falla del proveedor externo, verificando que el error sea capturado y notificado sin romper el estado de la aplicación.

## 5. Resultados y Conclusiones
La totalidad de las pruebas unitarias (8 en total) se ejecutaron de forma exitosa.

**Beneficios obtenidos:**
1. **Confianza en la lógica:** La validación de estados (cargando, error, logueado) está garantizada, reduciendo el riesgo de fallos silenciosos.
2. **Desacoplamiento:** Se comprobó que el `LoginViewModel` respeta la inyección de dependencias y responde correctamente a cualquier implementación del repositorio.
3. **Mantenibilidad:** Al tener el archivo `fakes.dart` y los tests aislados, cualquier refactorización futura en el Login arrojará errores inmediatos en la terminal si se rompe la lógica.

