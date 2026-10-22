# EcoRuta

Aplicación móvil para ordenar y aliviar la congestión de tránsito en el microcentro de Mendoza, desarrollada como Proyecto Integrador Grupal (EGI) para la materia Programación de Aplicaciones para Celulares.

Cliente: Secretaría de Movilidad, Municipalidad de Mendoza (Lic. Ondina Pastrelli).

## Equipo

| Integrante | Rol |
|---|---|
| Romina | Project Leader |
| Franco | Analista |
| Agustina | Desarrolladora |
| Matías | QA (testing) |

Los cuatro integrantes participan de la programación general del proyecto. Cada uno defiende su rol específico en la evaluación EGI.

## Alcances y límites

### Alcances (MVP)

1. Registro con email y contraseña, y login con Google OAuth (Firebase Auth)
2. Persistencia de sesión iniciada
3. Visualización de mapa con capa de tránsito en tiempo real (Google Maps SDK)
4. Cálculo y visualización de una ruta sugerida (Google Routes API)
5. Reporte de incidentes viales: tipo, foto y ubicación, guardado local
6. Alarma configurable para lugares habituales, que suena aunque la app esté cerrada
7. Sistema de puntos por uso en hora pico, calculado y almacenado localmente
8. Persistencia local de todos los datos generados por el usuario
9. Cobertura de testing sobre las funciones críticas del sistema

### Límites (fuera del MVP)

1. Sin canje real de puntos ni convenios con comercios adheridos
2. Sin notificaciones push proactivas
3. Sin encuestas automatizadas semanales
4. Sin algoritmo propio de reparto de carga entre rutas (queda como diseño conceptual)
5. Sin derivación automática de incidentes a áreas municipales reales
6. Sin backend propio ni base de datos remota para datos de uso (solo la autenticación usa un servicio en la nube, Firebase Auth)
7. Sin publicación real en Google Play Store (se documenta el proceso, no se ejecuta)
8. Sin validación de precisión de la capa de tránsito para el microcentro de Mendoza
9. Sin recuperación de contraseña por SMS ni multifactor (solo reseteo por email)

## Stack tecnológico

- **Framework:** Flutter / Dart (Dart 3.12 o posterior)
- **Arquitectura:** MVVM en capas (vista, ViewModel, repositorio, servicio)
- **Inyección de dependencias:** `provider`
- **Autenticación:** Firebase Authentication (email/contraseña + Google OAuth con `google_sign_in`)
- **Mapas y rutas:** Google Maps SDK, Google Routes API
- **Persistencia local:** `sqflite`, `shared_preferences`
- **Alarmas:** paquete `alarm` (alarmas del sistema que suenan con la app cerrada) y `permission_handler` para los permisos
- **Ubicación y fotos:** `geolocator`, `image_picker`, `path_provider`
- **CI:** GitHub Actions
- **Testing:** flutter_test (unit, widget e integration tests)

Todos los recursos utilizados se mantienen dentro de sus capas gratuitas.

## Arquitectura

El proyecto sigue MVVM organizado en capas. Los pedidos bajan y los datos suben, sin saltear capas:

- **Vista:** `vistas/` - pantallas y widgets. Dibuja el estado y avisa los toques del usuario. No llama a servicios ni a la base.
- **ViewModel:** `viewmodels/` - estado y lógica de presentación de cada pantalla. No usa `BuildContext`, `Navigator` ni `ScaffoldMessenger`: expone estado y la vista reacciona.
- **Repositorio:** `repositorios/` - fuente de verdad de cada tipo de dato. Convierte los datos crudos en modelos y traduce los errores (por ejemplo, los de Firebase a `ErrorAuth`).
- **Servicio:** `servicios/` - habla con el exterior: Firebase Auth, SQLite, GPS, alarmas del sistema. No guarda estado ni le muestra nada al usuario.
- **Modelo:** `modelos/` - clases de datos de Dart.

Cada pieza recibe sus dependencias por el constructor (inyección de dependencias), para poder cambiarlas por falsos en los tests.

Estado actual: tienen repositorio la autenticación, las alarmas y la ubicación. Lugares frecuentes, incidentes y usuarios todavía acceden a la base a través de su servicio (pendiente).

## Modelo de datos

La base local es `ecoruta.db` (sqflite), hoy en la **versión 7**. Entidades guardadas:

- **Usuario:** uid de Firebase, nombre y apellido, usuario, DNI, email, país, ciudad, departamento. **La contraseña no se guarda**: la verifica Firebase.
- **LugarFrecuente:** id, nombre, dirección, latitud y longitud, ícono (emoji), orden.
- **Alarma:** id, lugar asociado, hora, días, activa, orden y opciones de sonido (repetición, vibración, sonido, volumen).
- **Incidente:** id, tipos, descripción, calle, fecha, foto, latitud y longitud (opcionales si no hay GPS).

`PuntoRuta` (origen y destino de la pantalla principal) es un modelo en memoria: no se guarda en la base.

El detalle completo, el modelo objetivo y el historial de versiones de la base están en [`docs/modelo_datos.md`](docs/modelo_datos.md).

## Estructura de carpetas (`lib/`)

```
lib/
├── vistas/        # Pantallas y widgets (lo que el usuario ve)
├── viewmodels/    # Estado y lógica de cada pantalla
├── repositorios/  # Fuente de verdad de cada dato (auth, alarmas, ubicación)
├── servicios/     # Firebase Auth, SQLite, GPS y alarmas del sistema
└── modelos/       # Alarma, ErrorAuth, Incidente, LugarFrecuente, PuntoRuta, Usuario
```

## Cómo correr el proyecto

### Requisitos

1. Flutter SDK con **Dart 3.12 o posterior** (`flutter --version`). El código usa parámetros con nombre privados (`required this._repositorio`), que no compilan en versiones anteriores.
2. `flutter doctor` sin errores críticos.
3. Un dispositivo de prueba: emulador o celular físico por USB con la depuración USB activada.
4. El archivo `google-services.json` de Firebase, que se comparte por el Drive del grupo (no está en el repo).
5. Para el login con Google desde una compu nueva: cargar el SHA-1 de esa compu en la consola de Firebase.

### Pasos

```
git clone https://github.com/RamTech-26/EcoRuta.git
cd EcoRuta
```

1. Copiar `google-services.json` en `android/app/`.
2. Bajar las dependencias (con las versiones exactas de `pubspec.lock`):
   ```
   flutter pub get
   ```
3. Ver los dispositivos conectados y correr la app:
   ```
   flutter devices
   flutter run -d <id-del-dispositivo>
   ```

La primera vez que se abre una versión nueva, la base local se actualiza sola (migraciones en `DatabaseHelper`).

### Tests

```
flutter test
```

Todavía no hay tests en el repo: el plan está en `docs/plan_testing.md` (rama `feature/tests`). Ver también "Plan de testing" más abajo.

## Calidad de código

- `analysis_options.yaml` incluye `flutter_lints` y estas reglas extra: `prefer_const_constructors`, `prefer_single_quotes`, `directives_ordering`, `always_declare_return_types`, `unawaited_futures` y `only_throw_errors`.
- El proyecto pasa `flutter analyze` sin avisos (`No issues found!`) y está formateado con `dart format`.

### Rutina antes de cada commit

1. `dart format lib`
2. `flutter analyze` → tiene que decir **No issues found!**
3. Probar en un dispositivo lo que se tocó
4. `git add` de los archivos **por nombre** (no `git add .`) y revisar con `git status` que no aparezca `google-services.json`
5. Un commit por cambio, sin mezclar refactor con funcionalidad nueva

Las reglas que no hay que romper (comentarios que no se borran, navegación fuera del `build`, permisos, cambios en la base, etc.) están en [`docs/buenas_practicas.md`](docs/buenas_practicas.md).

## Convenciones

- Variables y funciones: `camelCase`, en español (ej: `calcularPuntos()`)
- Clases: `PascalCase` (ej: `PantallaMapa`)
- Archivos: minúsculas separadas por guion bajo (ej: `pantalla_mapa.dart`)
- Términos técnicos sin traducción natural en Flutter se mantienen en inglés: `viewmodel`, `login`, `widget`
- Widgets que no cambian se marcan como `const`
- Formato de código unificado con `dart format lib` antes de cada commit
- Comentarios `///` en lo público de ViewModels, repositorios y servicios; comentarios `//` para explicar el **por qué**; tareas pendientes como `// TODO(responsable): ...`

**Estructura por pantalla:**
Cada feature se compone de 4 piezas con el mismo nombre base:
- `vistas/pantalla_[feature].dart` -> ej: `pantalla_alarmas.dart`
- `viewmodels/[feature]_viewmodel.dart` -> ej: `alarma_viewmodel.dart`
- `servicios/[feature]_servicio.dart` -> ej: `alarma_servicio.dart`
- `repositorios/[feature]_repositorio.dart` -> ej: `alarma_repositorio.dart`

**Verbos para acciones comunes:**
- `cargar` para traer datos (ej: `cargarAlarmas()`)
- `guardar` para crear o actualizar (ej: `guardarAlarma()`)
- `eliminar` para borrar (ej: `eliminarAlarma()`)
- `reordenar` para cambiar el orden (ej: `reordenarAlarmas()`)
- `alternar` para estados on/off (ej: `alternarActivacion()`)
- `obtener` para permisos/ubicación (ej: `obtenerUbicacionActual()`)

## Estrategia de ramas (Git)

```
main
├── feature/login-google
├── feature/mapa-transito
├── feature/rutas-google
├── feature/reportar-incidente
├── feature/alarmas
└── feature/puntos
```

- `main` contiene siempre la versión funcional del proyecto
- Cada historia de usuario se desarrolla en su propia rama `feature/nombre-corto`
- Al finalizar, se abre un Pull Request hacia `main`
- Un integrante distinto al que programó revisa el Pull Request antes de aprobarlo
- Se mergea solo si el código compila y no rompe funcionalidades existentes
- La rama `feature` se elimina una vez fusionada

**Commits:** formato `tipo: qué se hizo`, en español. Tipos: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`.

```
feat: agrega login con Google
fix: corrige guardado de incidentes
test: agrega test de persistencia de alarmas
```

## Definition of Done

Una historia de usuario está terminada cuando:

1. El código cumple las convenciones definidas
2. Pasa por Pull Request con revisión de otro integrante
3. Tiene al menos un test que la cubre
4. Compila sin errores ni warnings
5. Cumple los criterios de aceptación del backlog
6. Está mergeada a `main`
7. Funciona en un dispositivo o emulador real

## Plan de testing

**Alcance:** por historia de usuario, cada una con al menos un test asociado a su criterio de aceptación.

**Tipos y responsables:**
- **Unit tests:** lógica de negocio aislada (cálculo de puntos, validaciones, persistencia). A cargo de la desarrolladora, a medida que programa cada función.
- **Widget tests:** comportamiento de pantallas ante interacciones del usuario. A cargo de QA.
- **Integration tests:** flujos completos de usuario en emulador/dispositivo real. A cargo de QA.

QA revisa los unit tests entregados por la desarrolladora, evalúa si la cobertura es suficiente y suma los tests necesarios para cubrir la experiencia completa. Ninguna historia se da por terminada sin su validación.

**Ejecución:**
- Manual: validaciones exploratorias, cambios visuales, revisión final de cada sprint
- Automatizada (GitHub Actions): unit tests y widget tests en cada Pull Request

Ninguna historia se mergea a `main` sin la aprobación de cobertura de QA.

## Gestión de riesgos

| Riesgo | Mitigación | Contingencia |
|---|---|---|
| Superar cuota gratuita de Google Maps/Routes API | Monitorear consumo semanalmente en Google Cloud Console | Cachear rutas ya consultadas para reducir llamadas |
| Cambios en políticas/precios de APIs de Google | Revisar documentación oficial antes de cada sprint que las use | Alternativa documentada (ej: OpenStreetMap) sin implementar |
| Dependencia de conexión a internet | — | Mensaje claro al usuario si no hay conexión |
| Falla de Firebase Auth | — | Login con email/contraseña como alternativa |
| Pérdida de datos locales al desinstalar | — | Documentado como limitación conocida |
| Bajo rendimiento en gama baja | Probar en dispositivo de gama media/baja en Sprint 5-6 | Reducir calidad de fotos de incidentes |
| Retraso en una historia por dificultad técnica | Estimar con margen, priorizar HU críticas | Recortar alcance de esa HU al mínimo funcional |
| Ausencia de un integrante | Todos conocen todo el proyecto | Redistribuir su tarea esa semana |
| Falta de tiempo para testing | Testing continuo por sprint | Priorizar tests de HU críticas |
| Incompatibilidad de versiones | Fijar versiones con `pubspec.lock` versionado | Volver a la última versión estable en Git |
| Pérdida de código por mal manejo de Git | Seguir estrategia de ramas y PR | Recuperar desde el último commit funcional en `main` |
| Errores de permisos no manejados | Pedir cada permiso en contexto, explicando para qué | Mensaje explicativo y acceso a Ajustes si el usuario los rechaza |
| Cambio de alcance de último momento | Alcance ya documentado y acordado | Pedidos nuevos se anotan como trabajo futuro |
| Emulador/dispositivo no disponible | Cada integrante prueba en su propio equipo | Usar el dispositivo de otro integrante como respaldo |

## Planificación por sprints (Scrum, 2 semanas c/u)

| Sprint | Fechas | Objetivo |
|---|---|---|
| 1 | 7/9 – 20/9 | Arquitectura base, interfaces, autenticación |
| 2 | 21/9 – 4/10 | Mapa y capa de tránsito |
| 3 | 5/10 – 18/10 | Rutas con Google Routes API |
| 4 | 19/10 – 1/11 | Reporte de incidentes y persistencia local |
| 5 | 2/11 – 15/11 | Alarma en background y puntos locales |
| 6 (buffer) | 16/11 – 23/11 | Integración final, testing y ensayo de defensa |

**Entrega del MVP:** 23/11/26 — una semana antes de la evaluación EGI (1/12/26).

## Credenciales y archivos privados

- El archivo `google-services.json` de Firebase **no se sube al repositorio** (está en `.gitignore`). Nunca usar `git add -f` con ese archivo.
- Las API keys de Google (cuando se integre el mapa) tampoco se suben: se gestionan con `--dart-define` o un archivo `.env` ignorado por Git.
- Las credenciales se comparten entre el equipo por el Drive del grupo.
- `pubspec.lock` **sí** se sube: no tiene datos privados y asegura que todos compilen con las mismas versiones.