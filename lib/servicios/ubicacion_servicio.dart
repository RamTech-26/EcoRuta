import 'package:geolocator/geolocator.dart';

/// Qué pasó al pedir la ubicación actual.
enum EstadoUbicacion {
  ok,

  /// La ubicación (GPS) del celular está apagada.
  servicioApagado,

  /// El usuario no dio permiso (se le puede volver a pedir).
  sinPermiso,

  /// El usuario negó el permiso para siempre: solo se cambia desde ajustes.
  sinPermisoPermanente,

  /// Timeout u otro error al obtener la posición.
  error,
}

class ResultadoUbicacion {
  final EstadoUbicacion estado;
  final Position? posicion;

  const ResultadoUbicacion(this.estado, [this.posicion]);
}

/// Acceso al GPS del celular. No muestra nada en pantalla: devuelve
/// un estado y la vista decide qué diálogo o aviso mostrar.
class UbicacionServicio {
  Future<ResultadoUbicacion> obtenerActual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ResultadoUbicacion(EstadoUbicacion.servicioApagado);
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(EstadoUbicacion.sinPermisoPermanente);
      }
      if (permiso == LocationPermission.denied) {
        return const ResultadoUbicacion(EstadoUbicacion.sinPermiso);
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return ResultadoUbicacion(EstadoUbicacion.ok, posicion);
    } catch (_) {
      return const ResultadoUbicacion(EstadoUbicacion.error);
    }
  }

  /// Abre los ajustes de ubicación del sistema (para activar el GPS).
  Future<bool> abrirAjustesUbicacion() => Geolocator.openLocationSettings();

  /// Abre los ajustes de la app (para dar el permiso negado para siempre).
  Future<bool> abrirAjustesApp() => Geolocator.openAppSettings();
}