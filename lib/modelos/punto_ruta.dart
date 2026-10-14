import 'lugar_frecuente.dart';

/// De dónde salió un punto de la ruta (origen o destino).
enum TipoPunto {
  /// GPS del celular.
  ubicacionActual,

  /// Un lugar frecuente guardado por el usuario.
  lugarFrecuente,

  /// Texto escrito a mano: todavía no tiene coordenadas.
  manual,

  /// Elegido tocando el mapa (se usa cuando el mapa esté listo).
  mapa,
}

/// Un punto de la ruta: lo que se muestra en el campo y, si se conocen,
/// sus coordenadas. La ruta sugerida solo se puede pedir cuando origen
/// y destino tienen coordenadas.
class PuntoRuta {
  final String texto;
  final double? latitud;
  final double? longitud;
  final TipoPunto tipo;

  /// Id del lugar frecuente, si el punto viene de uno.
  final String? lugarId;

  const PuntoRuta({
    required this.texto,
    required this.tipo,
    this.latitud,
    this.longitud,
    this.lugarId,
  });

  bool get tieneCoordenadas => latitud != null && longitud != null;

  factory PuntoRuta.ubicacionActual(double latitud, double longitud) =>
      PuntoRuta(
        texto: 'Mi ubicación actual',
        tipo: TipoPunto.ubicacionActual,
        latitud: latitud,
        longitud: longitud,
      );

  /// Un lugar guardado con 0,0 no tiene ubicación real.
  factory PuntoRuta.desdeLugar(LugarFrecuente lugar) {
    final sinUbicacion = lugar.latitud == 0 && lugar.longitud == 0;
    return PuntoRuta(
      texto: lugar.direccion,
      tipo: TipoPunto.lugarFrecuente,
      latitud: sinUbicacion ? null : lugar.latitud,
      longitud: sinUbicacion ? null : lugar.longitud,
      lugarId: lugar.id,
    );
  }

  factory PuntoRuta.manual(String texto) =>
      PuntoRuta(texto: texto, tipo: TipoPunto.manual);

  /// Para cuando el mapa esté listo: el usuario toca un punto y el mapa
  /// devuelve las coordenadas (y si puede, una dirección para mostrar).
  factory PuntoRuta.desdeMapa({
    required double latitud,
    required double longitud,
    String? texto,
  }) =>
      PuntoRuta(
        texto: texto ??
            '${latitud.toStringAsFixed(5)}, ${longitud.toStringAsFixed(5)}',
        tipo: TipoPunto.mapa,
        latitud: latitud,
        longitud: longitud,
      );
}