# Buenas prácticas de EcoRuta

Responsable: Franco (Analista). Actualizado: 21/10/2026.

Este documento reúne las prácticas que seguimos en EcoRuta y las reglas que **no hay que romper** al modificar el código.

## 1. Prácticas que aplicamos

| Tema | Práctica |
|---|---|
| **Arquitectura en capas** | Vista → ViewModel → Repositorio → Servicio. El ViewModel no navega ni usa `BuildContext`: expone estado y la vista reacciona. El servicio no le muestra nada al usuario. Los errores se traducen en el repositorio y el ViewModel decide qué mostrar. Las dependencias se reciben por constructor. |
| **ViewModels (ChangeNotifier)** | Lo que se abre se cierra: cada `addListener` tiene su `removeListener` en `dispose`, y cada suscripción a un stream se cancela. |
| **Código limpio** | `analysis_options.yaml` con reglas extra, `dart format`, `flutter analyze` sin avisos, comentarios `///` en lo público de ViewModels y servicios, comentarios que explican el **por qué**, `TODO(responsable)`, una regla en un solo lugar, nada de comentarios que repiten el código. |
| **Commits y refactoring** | Commits chicos, uno por cambio. Refactor y funcionalidad nueva van en commits separados. Probar después de cada paso. |
| **Código asíncrono** | `Future<void>` en vez de `void f() async` (salvo callbacks de widgets), `await` en todo lo que devuelve un `Future` (regla `unawaited_futures`), `mounted` / `context.mounted` después de cada `await` antes de usar el `context`. |
| **Permisos y avisos al usuario** | El permiso se pide **en contexto**, explicando para qué sirve y nunca al abrir la app. La app **sigue funcionando si dicen que no**: se avisa qué se pierde, sin insistir, y se ofrece ir a Ajustes si el permiso quedó negado para siempre. El plugin queda detrás de un servicio y la decisión de qué mostrar es de la vista. |
| **Dependencias** | `pubspec.lock` se sube al repo para que todo el equipo compile con las mismas versiones. |
| **Diseño adaptable** | `MediaQuery.sizeOf` en vez de `MediaQuery.of(context).size`. El teclado no tiene que tapar los campos: dejar que el formulario se achique, o sumar `MediaQuery.viewInsetsOf(context).bottom` al scroll. |

Las alarmas usan la notificación propia del paquete `alarm`; por ahora no se usa `flutter_local_notifications`.

## 2. Comentarios que no se borran

Un comentario que explica **por qué** el código está escrito así no se borra, aunque parezca obvio. Si algo no se entiende, se pregunta en el grupo antes de borrarlo.

| Archivo | Comentario | Qué pasa si se ignora |
|---|---|---|
| `lugar_frecuente_viewmodel.dart` (`eliminarLugar`) | El ON DELETE CASCADE solo borra las filas de la base; las alarmas programadas hay que cancelarlas a mano. | Las alarmas de un lugar borrado siguen sonando. |
| `lugar_frecuente_viewmodel.dart` (`tieneUbicacion`) | Un lugar viejo guardado con 0,0 cuenta como "sin ubicación". | Lugares sin GPS aparecen en el medio del océano. |
| `principal_viewmodel.dart` (`_asignar`) | Primero se guarda el punto y después el texto. | El listener del texto toma el punto como escrito a mano y pierde las coordenadas. |
| `alarma_viewmodel.dart` (`_escucharEventosDeAlarma`) | La alarma que está sonando no se vuelve a programar. | La alarma se corta a los segundos y solo vibra. |
| `alarma_viewmodel.dart` y `lugar_frecuente_viewmodel.dart` (`reordenar`) | `newIndex` ya viene corregido por `onReorderItem`: no hay que restarle 1. | Reordenar hacia abajo deja el elemento un lugar más arriba. |
| `alarma_servicio.dart` (`onRing`) | El stream del plugin se comparte como broadcast. | Error "Stream has already been listened to". |
| `database_helper.dart` (`onConfigure`) | `PRAGMA foreign_keys = ON`: sin esto, el ON DELETE CASCADE no hace nada. | Quedan alarmas huérfanas. |
| `database_helper.dart` (migración v7) | SQLite en Android viejo no tiene DROP COLUMN; por eso se recrea la tabla. | La migración falla en celulares viejos. |
| `pantalla_login.dart` y `pantalla_registro.dart` (`_alCambiarEstado`) | La navegación no va en el `build`. | Se abren varias pantallas a la vez ("temblor") o se hacen varios `pop`. |
| `pantalla_registro.dart` | El fondo va afuera del `Scaffold`. | El teclado vuelve a tapar los campos de abajo. |

**Sí se borran:** los comentarios que repiten lo que dice el código, las marcas de edición (`// <- AGREGADO`, `// <-- NUEVO`), los títulos decorativos (`// --- FIX 1 ---`), el código comentado "por las dudas" (para eso está Git) y los comentarios que quedaron desactualizados.

## 3. Reglas de código

- **No navegar ni mostrar avisos desde el `build`.** Se hace en un listener del ViewModel (`_alCambiarEstado`) que se registra una vez y se quita en `dispose`. El `build` se ejecuta muchas veces (por ejemplo, mientras se cierra el teclado).
- **El ViewModel no usa `BuildContext`, `Navigator` ni `ScaffoldMessenger`.**
- **Los servicios no le muestran nada al usuario ni abren Ajustes por su cuenta.** Devuelven un resultado y la vista decide.
- **No lanzar textos** (`throw 'mensaje'`): usar excepciones tipadas como `ErrorAuth`. El analizador lo marca con `only_throw_errors`.
- **Los permisos se piden solo después de explicar para qué**, nunca al abrir la app ni adentro del servicio. Si los niegan, la app sigue andando y se ofrece ir a Ajustes.
- **No guardar la contraseña** en la base local ni en el modelo `Usuario`: la verifica Firebase.
- **No duplicar reglas.** La conversión de íconos a emoji está solo en `LugarFrecuente.emoji`; las columnas de usuarios, solo en `_columnasUsuarios`.
- **El emoji 🏋️ se escribe como `'\u{1F3CB}\u{FE0F}'`.** Algunos editores le borran el carácter invisible si se escribe el emoji directo.
- **Cambios en la base:** subir `_version` en `DatabaseHelper` y agregar un `if (oldVersion < N)` en `onUpgrade`. Nunca cambiar solo el `onCreate`: los celulares que ya tienen la app no lo vuelven a correr. Anotar la versión nueva en `docs/modelo_datos.md`.
- **No desactivar reglas** de `analysis_options.yaml` para sacar un aviso: se arregla el código. Si una regla de verdad no aplica en una línea, se usa `// ignore: regla` con un comentario del por qué.
- **Antes de reemplazar una API "deprecated"**, revisar si cambian los parámetros o su significado (pasó con `onReorder` → `onReorderItem`) y probar en un dispositivo.

## 4. Configuración que no se toca

- `google-services.json` **nunca** se sube. No usar `git add -f` con ese archivo.
- La excepción `!pubspec.lock` del `.gitignore` se queda.
- Las reglas de `analysis_options.yaml` se cambian solo si lo acuerda el grupo.

## 5. Rutina antes de cada commit

1. `dart format lib`
2. `flutter analyze` → tiene que decir **No issues found!**
3. Probar en un dispositivo lo que se tocó
4. `git add` de los archivos **por nombre** (no `git add .`) y `git status` para revisar que no aparezca `google-services.json`
5. Un commit por cambio, con mensaje `tipo: qué se hizo` (`feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`)
6. Nunca hacer commit con `flutter analyze` mostrando avisos o con tests fallando