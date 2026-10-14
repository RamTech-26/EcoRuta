# Plan de Testing General - EcoRuta MVP
Sprint 1 - Rol QA (Matías)

## 1. Objetivo
Validar que las funciones críticas del MVP funcionen según los requisitos RF01-RF12 y RNF01-RNF06, con cobertura unitaria y widget sobre persistencia, navegación y consumo de API.

## 2. Alcances y Límites
**Qué SÍ se testea:**
- Mapa con tránsito (RF01)
- Ruta sugerida (RF02)
- Reporte de incidentes local (RF03, RF04)
- Lugares frecuentes CRUD (RF05.1 - RF05.3 NUEVO)
- Alarmas sobre lugares frecuentes (RF06, RF07)
- Puntos locales (RF08, RF09)
- Auth email/pass y Google + sesión persistente (RF10, RF11, RF12)
- Persistencia local sin conexión (RNF03)

**Qué NO se testea en MVP (fuera de alcance):**
- Canje real de puntos, push proactivas, encuestas, algoritmo propio de reparto de carga, derivación municipal, backend remoto, publicación Play Store, recuperación SMS.

## 3. Tipos de Testing y Responsables
- **Unit:** Modelos (toMap/fromMap/copyWith/==), Servicios (database_helper, lugar_frecuente_servicio, ubicacion_servicio, alarma_servicio), ViewModels (login, principal, reporte_incidente, lugares_frecuentes). **A cargo de Agustina (desarrolladora)**, escritos a medida que programa cada función.
- **Widget:** Pantallas con ListenableBuilder (login, principal, reporte, lugares). **A cargo de Matías (QA).**
- **Integración:** Consumo Routes API + Maps SDK. **A cargo de Matías (QA).**
- **E2E:** Flujo login -> mapa -> guardar lugar -> pedir ruta -> alarma. **A cargo de Matías (QA).**

**Rol de QA en la cobertura:** Matías revisa los unit tests entregados por Agustina, evalúa si la cobertura es suficiente y suma los widget/integration/E2E tests necesarios. Ninguna historia se aprueba sin su validación, conforme al Plan de Testing general del proyecto.

## 4. Herramientas
- `flutter test` + `flutter_test`
- `shared_preferences` / `sqflite` en memoria para tests de persistencia
- Fakes para Firebase Auth y Google Maps
- Logs: `flutter test --reporter expanded > log_ok.txt`

## 5. Criterios de Aceptación por Historia (testables)

**Épica 1 Auth**
- HU01 Registro email/pass (RF10): email formato válido, pass >=6, error si email existe
- HU02 Login Google (RF11): usa Firebase Auth + OAuth, si OK -> pushReplacement a principal
- HU03 Sesión persistida (RF12): al reabrir logueado, no pide login

**Épica 2 Mapa y tránsito**
- HU04 Mapa (RF01): capa tránsito visible, colores congestión, centrado Mendoza
- HU05 Ruta (RF02): input origen/destino, ruta dibujada, tiempo estimado visible

**Épica 3 Lugares Frecuentes (NUEVO)**
- HU06 Guardar (RF05.1): permite nombre + lat/lng (mapa o dirección), valida nombre no vacío, toMap/fromMap correcto
- HU07 Editar/Eliminar (RF05.2): edición actualiza, eliminación pide confirmación si tiene alarma asociada (Riesgo 15)
- HU08 Usar como destino (RF05.3): lugares aparecen como accesos rápidos en pantalla ruta, tap carga destino auto

**Épica 4 Incidentes**
- HU09 Reportar (RF03): form tipo + foto + ubicación autodetectada, guardado local
- HU10 Listar (RF04): lista local ordenada por fecha desc

**Épica 5 Alarmas**
- HU11 Configurar (RF06): alarma asociada a lugar_frecuente existente (FK), guarda horario
- HU12 Background (RF07): workmanager dispara notificación con app cerrada

**Épica 6 Puntos**
- HU13 Sumar (RF08): uso en hora pico acumula local
- HU14 Ver (RF09): pantalla/sección con total

**Épica 7 Calidad**
- HU15 Unit persistencia y navegación: cobertura mínima módulos críticos, `flutter test` verde
- HU16 Integración Routes API: respuesta OK dibuja ruta, error muestra mensaje y no crashea

## 6. Validación de requisitos no funcionales
- RNF01 (versión mínima Android): verificar manualmente en emulador con API mínima definida en `build.gradle`
- RNF02 (cuota gratuita APIs): revisar consumo en consola de Google Cloud antes de cerrar cada sprint que use Maps/Routes
- RNF03 (persistencia sin conexión): cubierto con tests de sqflite/shared_preferences en memoria (ver sección 3)
- RNF04 (registro y login obligatorio): cubierto por HU01-HU03
- RNF05 (arquitectura MVVM): revisión de código en cada Pull Request, no automatizable
- RNF06 (cobertura de tests en funciones críticas): validado por `flutter test` + revisión de QA antes de cada merge

## 7. Cronograma por Sprint
- S1 (7/9-20/9): Plan general + CA login/registro (este doc)
- S2 (21/9-4/10): Unit navegación + CRUD lugares_frecuentes (shared_preferences/sqflite)
- S3 (5/10-18/10): Integración Routes API + uso lugares como destino rápido
- S4 (19/10-1/11): Unit persistencia incidentes
- S5 (2/11-15/11): Testing alarma + caso borde: eliminar lugar con alarma (R15 -> confirmación + cascada)
- S6 (16/11-23/11): E2E + informe bugs

## 8. Definition of Done para Testing
- `flutter analyze` sin errores
- `flutter test` -> All tests passed
- CA de la HU validado manualmente y con test donde aplica
- Commit con mensaje `test: ...` o `feat: ...` sobre la rama `feature/nombre-corto` de la historia correspondiente, con Pull Request revisado por otro integrante antes de mergear a `main`

## 9. Riesgo clave testeable
- R15 NUEVO: Inconsistencia al eliminar lugar frecuente con alarma asociada. Mitigación: test de HU07 con mock de alarma_servicio, espera dialog confirmación y verifica borrado en cascada. **Este riesgo debe agregarse también a la tabla general de Gestión de riesgos del proyecto (README), no solo documentarse acá.**
