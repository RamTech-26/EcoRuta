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
6. Alarma configurable para lugares habituales, ejecutada en segundo plano (workmanager)
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

- **Framework:** Flutter / Dart
- **Arquitectura:** MVVM
- **Autenticación:** Firebase Authentication (email/contraseña + Google OAuth)
- **Mapas y rutas:** Google Maps SDK, Google Routes API
- **Persistencia local:** sqflite, shared_preferences
- **Tareas en segundo plano:** workmanager
- **CI:** GitHub Actions
- **Testing:** flutter_test (unit, widget e integration tests)

Todos los recursos utilizados se mantienen dentro de sus capas gratuitas.

## Arquitectura

El proyecto sigue el patrón MVVM:

- **View:** pantallas y widgets de Flutter, sin lógica de negocio
- **ViewModel:** maneja el estado y la lógica de presentación de cada pantalla
- **Model:** agrupa dos fuentes de datos
  - Servicios externos: Firebase Auth, Google Maps/Routes API
  - Persistencia local: sqflite, shared_preferences

## Modelo de datos

Entidades principales almacenadas localmente:

- **Usuario:** caché mínima de datos de Firebase Auth (uid, email, nombre, método de autenticación)
- **Incidente:** id, uid del usuario, tipo, foto, ubicación, fecha
- **Alarma:** id, uid del usuario, nombre del lugar, ubicación, horario, estado
- **Puntaje:** uid del usuario, puntos totales, última actividad

## Estructura de carpetas (`lib/`)

```
lib/
├── vistas/        # Pantallas (lo que el usuario ve)
├── viewmodels/    # Lógica de cada pantalla
├── modelos/       # Clases de datos (Usuario, Incidente, Alarma, Puntaje)
└── servicios/     # Conexión con Firebase, Google Maps/Routes y persistencia local
```

## Convenciones de código

- Variables y funciones: `camelCase`, en español (ej: `calcularPuntos()`)
- Clases: `PascalCase` (ej: `PantallaMapa`)
- Archivos: minúsculas separadas por guion bajo (ej: `pantalla_mapa.dart`)
- Toda función no evidente debe tener un comentario breve explicando qué hace
- Widgets que no cambian se marcan como `const`
- Formato de código unificado con `dart format` antes de cada commit

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

**Commits:** formato `tipo: qué se hizo`, en español.

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
| Incompatibilidad de versiones | Fijar versiones en `pubspec.yaml` desde el inicio | Volver a la última versión estable en Git |
| Pérdida de código por mal manejo de Git | Seguir estrategia de ramas y PR | Recuperar desde el último commit funcional en `main` |
| Errores de permisos no manejados | Probar permisos al implementar cada feature | Mensaje explicativo si el usuario los rechaza |
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

## Variables de entorno

- Las API keys de Google y el archivo `google-services.json` de Firebase **no se suben al repositorio**
- Se gestionan mediante `.env` (paquete `flutter_dotenv`) o `--dart-define`
- Ambos archivos están incluidos en `.gitignore`
- Las credenciales se comparten entre el equipo por un canal privado

## Requisitos para levantar el proyecto

1. Flutter SDK instalado y en el PATH
2. `flutter doctor` sin errores críticos
3. Un dispositivo de prueba disponible (emulador o celular físico por USB)
4. Archivo `.env` y `google-services.json` provistos por el equipo (no incluidos en el repo)
