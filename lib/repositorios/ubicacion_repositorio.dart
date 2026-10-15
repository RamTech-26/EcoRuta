import '../servicios/ubicacion_servicio.dart';

abstract class UbicacionRepositorio {
  Future<ResultadoUbicacion> obtenerActual();
  Future<bool> abrirAjustesUbicacion();
  Future<bool> abrirAjustesApp();
}

class UbicacionRepositorioImpl implements UbicacionRepositorio {
  final UbicacionServicio _servicio;

  UbicacionRepositorioImpl(this._servicio);

  @override
  Future<ResultadoUbicacion> obtenerActual() {
    return _servicio.obtenerActual();
  }

  @override
  Future<bool> abrirAjustesUbicacion() {
    return _servicio.abrirAjustesUbicacion();
  }

  @override
  Future<bool> abrirAjustesApp() {
    return _servicio.abrirAjustesApp();
  }
}
