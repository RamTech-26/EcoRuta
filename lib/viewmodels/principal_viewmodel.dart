import 'package:flutter/material.dart';

import '../modelos/lugar_frecuente.dart';
import '../modelos/punto_ruta.dart';
import '../servicios/lugar_frecuente_servicio.dart';
import '../servicios/ubicacion_servicio.dart';

/// Los dos campos de la ruta.
enum CampoRuta { origen, destino }

/// ViewModel de la pantalla principal.
/// Maneja el origen y el destino de la ruta, los lugares frecuentes
/// para elegir, y el panel deslizable inferior.
class PrincipalViewModel extends ChangeNotifier {
  final TextEditingController controladorOrigen = TextEditingController();
  final TextEditingController controladorDestino = TextEditingController();

  final DraggableScrollableController controladorPanel =
      DraggableScrollableController();

  final LugarFrecuenteServicio _lugarServicio = LugarFrecuenteServicio();
  final UbicacionServicio _ubicacionServicio = UbicacionServicio();

  bool _cerrado = false;

  PrincipalViewModel() {
    controladorOrigen.addListener(() => _alCambiarTexto(CampoRuta.origen));
    controladorDestino.addListener(() => _alCambiarTexto(CampoRuta.destino));
  }

  // ---------- Origen y destino ----------

  PuntoRuta? _origen;
  PuntoRuta? _destino;
  CampoRuta? _buscandoUbicacion;

  PuntoRuta? get origen => _origen;
  PuntoRuta? get destino => _destino;

  /// Campo que está esperando el GPS (para mostrar la ruedita).
  CampoRuta? get buscandoUbicacion => _buscandoUbicacion;

  /// Para el sprint 3: la ruta se puede pedir cuando los dos puntos
  /// tienen coordenadas.
  bool get rutaLista =>
      (_origen?.tieneCoordenadas ?? false) &&
      (_destino?.tieneCoordenadas ?? false);

  TextEditingController controlador(CampoRuta campo) =>
      campo == CampoRuta.origen ? controladorOrigen : controladorDestino;

  PuntoRuta? punto(CampoRuta campo) =>
      campo == CampoRuta.origen ? _origen : _destino;

  void _guardarPunto(CampoRuta campo, PuntoRuta? nuevo) {
    if (campo == CampoRuta.origen) {
      _origen = nuevo;
    } else {
      _destino = nuevo;
    }
  }

  /// Pone un punto en el campo. Primero guarda el punto y después el texto,
  /// así el listener del texto no lo confunde con algo escrito a mano.
  void _asignar(CampoRuta campo, PuntoRuta? nuevo) {
    _guardarPunto(campo, nuevo);
    controlador(campo).text = nuevo?.texto ?? '';
    _notificar();
  }

  /// Pide el GPS y, si sale bien, lo pone en el campo.
  /// Devuelve el estado para que la vista muestre el aviso que corresponda.
  Future<EstadoUbicacion> usarUbicacionActual(CampoRuta campo) async {
    _buscandoUbicacion = campo;
    _notificar();

    final resultado = await _ubicacionServicio.obtenerActual();

    _buscandoUbicacion = null;
    final posicion = resultado.posicion;
    if (resultado.estado == EstadoUbicacion.ok && posicion != null) {
      _asignar(
        campo,
        PuntoRuta.ubicacionActual(posicion.latitude, posicion.longitude),
      );
    } else {
      _notificar();
    }
    return resultado.estado;
  }

  void elegirLugar(CampoRuta campo, LugarFrecuente lugar) =>
      _asignar(campo, PuntoRuta.desdeLugar(lugar));

  /// Para cuando el mapa esté listo: el mapa llama a esto con el punto
  /// que tocó el usuario.
  void asignarDesdeMapa(
    CampoRuta campo, {
    required double latitud,
    required double longitud,
    String? texto,
  }) =>
      _asignar(
        campo,
        PuntoRuta.desdeMapa(latitud: latitud, longitud: longitud, texto: texto),
      );

  void limpiar(CampoRuta campo) => _asignar(campo, null);

  Future<bool> abrirAjustesUbicacion() =>
      _ubicacionServicio.abrirAjustesUbicacion();

  Future<bool> abrirAjustesApp() => _ubicacionServicio.abrirAjustesApp();

  /// Si el usuario escribe en el campo, el punto pasa a ser "manual"
  /// (sin coordenadas) o se borra si dejó el campo vacío.
  void _alCambiarTexto(CampoRuta campo) {
    final texto = controlador(campo).text;
    final actual = punto(campo);
    if (actual != null && actual.texto == texto) return;

    final nuevo = texto.trim().isEmpty ? null : PuntoRuta.manual(texto);
    final cambioDeTipo = actual?.tipo != nuevo?.tipo;
    _guardarPunto(campo, nuevo);
    // Solo avisamos si cambió el tipo, no en cada letra.
    if (cambioDeTipo) _notificar();
  }

  // ---------- Lugares frecuentes ----------

  List<LugarFrecuente> _lugares = [];

  List<LugarFrecuente> get lugares => _lugares;

  Future<void> cargarLugares() async {
    try {
      _lugares = await _lugarServicio.obtenerTodos();
    } catch (_) {
      _lugares = [];
    }
    _actualizarPuntoDeLugar(CampoRuta.origen);
    _actualizarPuntoDeLugar(CampoRuta.destino);
    _notificar();
  }

  /// Si el lugar elegido se editó, toma las coordenadas nuevas (sin cambiar
  /// el texto del campo). Si se borró, queda como texto escrito a mano.
  void _actualizarPuntoDeLugar(CampoRuta campo) {
    final actual = punto(campo);
    if (actual == null || actual.tipo != TipoPunto.lugarFrecuente) return;

    final encontrados = _lugares.where((l) => l.id == actual.lugarId);
    if (encontrados.isEmpty) {
      _guardarPunto(campo, PuntoRuta.manual(actual.texto));
      return;
    }
    final lugar = PuntoRuta.desdeLugar(encontrados.first);
    _guardarPunto(
      campo,
      PuntoRuta(
        texto: actual.texto,
        tipo: TipoPunto.lugarFrecuente,
        latitud: lugar.latitud,
        longitud: lugar.longitud,
        lugarId: lugar.lugarId,
      ),
    );
  }

  // ---------- Panel deslizable ----------

  /// Abre o cierra el panel deslizable según su posición actual.
  void alternarPanel() {
    final abierto = controladorPanel.size > 0.2;
    controladorPanel.animateTo(
      abierto ? 0.1 : 0.6,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void cerrarPanel() {
    controladorPanel.animateTo(
      0.1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  /// Evita avisar a la vista si ya se cerró (por ejemplo, si el GPS
  /// responde después de salir de la pantalla).
  void _notificar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    controladorOrigen.dispose();
    controladorDestino.dispose();
    controladorPanel.dispose();
    super.dispose();
  }
}