# Requisitos — EcoRuta MVP

Documento de requisitos funcionales y no funcionales del MVP de EcoRuta.
Responsable: Franco (Analista). Basado en la checklist v2 del equipo.

## Requisitos funcionales (RF)

| ID | Requisito | Historias | Sprint |
|---|---|---|---|
| RF01 | El sistema debe mostrar un mapa con la capa de tránsito en tiempo real | HU04 | 2 |
| RF02 | El sistema debe calcular y mostrar una ruta sugerida entre origen y destino | HU05 | 3 |
| RF03 | El usuario debe poder reportar un incidente (tipo, foto, ubicación) | HU09 | 4 |
| RF04 | El sistema debe guardar los incidentes reportados localmente | HU10 | 4 |
| RF05 | El usuario debe poder guardar, editar y eliminar lugares frecuentes (casa, trabajo, gimnasio, etc.) | HU06, HU07, HU08 | 2 (HU08 se completa en 3) |
| RF06 | El usuario debe poder configurar una alarma sobre un lugar frecuente ya guardado | HU11 | 5 |
| RF07 | El sistema debe ejecutar la alarma en segundo plano | HU12 | 5 |
| RF08 | El sistema debe sumar puntos al usuario cuando usa la app en hora pico | HU13 | 5 |
| RF09 | El sistema debe mostrar el puntaje acumulado del usuario | HU14 | 5 |
| RF10 | El usuario debe poder registrarse con email y contraseña | HU01 | 1 |
| RF11 | El usuario debe poder iniciar sesión con su cuenta de Google | HU02 | 1 |
| RF12 | El sistema debe mantener la sesión iniciada entre usos | HU03 | 1 |

### Dependencias entre requisitos

- RF06 depende de RF05: una alarma siempre se asocia a un lugar frecuente existente.
- RF05 depende de RF01: la ubicación de un lugar frecuente se elige en el mapa o se busca por dirección.
- RF08 depende de RF02: los puntos se otorgan al seguir una ruta en hora pico.

## Requisitos no funcionales (RNF)

| ID | Requisito | Criterio de verificación |
|---|---|---|
| RNF01 | La app debe funcionar en Android 7.0 o superior (API 24) — *propuesto, a confirmar por el equipo* | Se instala y ejecuta en un emulador con API 24 |
| RNF02 | El consumo de las APIs de Google debe mantenerse dentro de la franja gratuita | Revisión semanal del consumo en Google Cloud Console |
| RNF03 | Los datos del usuario deben persistir localmente sin conexión a internet (excepto mapa y rutas) | Los datos siguen disponibles en modo avión |
| RNF04 | La app debe requerir registro y login, con opción de Google OAuth vía Firebase Auth | No se accede a la pantalla principal sin sesión iniciada |
| RNF05 | El código debe seguir una arquitectura MVVM | Las vistas no acceden a servicios ni a la base de datos directamente |
| RNF06 | Las funciones críticas deben tener cobertura de tests unitarios | `flutter test` corre sin errores sobre persistencia, navegación y consumo de API |

## Estado al 21/09/2026

| Requisito | Estado | Observación |
|---|---|---|
| RF10 | Parcial | Registro implementado con SQLite local; falta migrar a Firebase Auth |
| RF11 | Pendiente | Botón presente en la UI, sin funcionalidad |
| RF12 | Pendiente | No hay persistencia de sesión |
| RF01 | Pendiente | La pantalla principal tiene un espacio reservado para el mapa |
| RF05 | Parcial | CRUD de lugares hecho; falta ubicación real (lat/long) y uso como destino |
| RNF06 | Pendiente | Solo existe el test por defecto de Flutter |