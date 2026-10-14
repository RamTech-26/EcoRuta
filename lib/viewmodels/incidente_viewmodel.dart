import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../modelos/incidente.dart';
import '../servicios/incidente_servicio.dart';

/// ViewModel de incidentes.
/// Maneja el formulario de reporte (tipos, foto y ubicación GPS)
/// y la lista de incidentes guardados.
class IncidenteViewModel extends ChangeNotifier {
  final IncidenteServicio _servicio = IncidenteServicio();
  final ImagePicker _picker = ImagePicker();

  // Tipos disponibles en el formulario
  final List<String> tiposDisponibles = const [
    'Choque',
    'Semáforo roto',
    'Accidente',
    'Ruta rota',
    'Inundación',
    'Otros',
  ];

  // Tipos marcados
  final List<String> _seleccionados = [];
  List<String> get seleccionados => _seleccionados;

  bool estaSeleccionado(String tipo) => _seleccionados.contains(tipo);

  void alternarTipo(String tipo, bool marcado) {
    if (marcado) {
      _seleccionados.add(tipo);
    } else {
      _seleccionados.remove(tipo);
    }
    notifyListeners();
  }

  bool get mostrarCampoOtros => _seleccionados.contains('Otros');

  // ---------- Foto ----------

  String? _rutaFoto;
  String? get rutaFoto => _rutaFoto;
  bool get tieneFoto => _rutaFoto != null;

  /// Abre la cámara (o la galería) y guarda una copia de la foto
  /// en la carpeta de la app, para que no se pierda.
  Future<void> tomarFoto({bool desdeGaleria = false}) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: desdeGaleria ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 70, // comprime para no ocupar tanto espacio
        maxWidth: 1280,
      );
      if (imagen == null) return; // el usuario canceló

      final carpetaApp = await getApplicationDocumentsDirectory();
      final carpetaFotos = Directory(p.join(carpetaApp.path, 'incidentes'));
      await carpetaFotos.create(recursive: true);

      final destino = p.join(
        carpetaFotos.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(imagen.path).copy(destino);

      _rutaFoto = destino;
      _error = null;
    } catch (e) {
      _error = 'No se pudo obtener la foto';
    }
    notifyListeners();
  }

  void quitarFoto() {
    _rutaFoto = null;
    notifyListeners();
  }

  // ---------- Ubicación GPS ----------

  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;
  String? _avisoUbicacion;

  double? get latitud => _latitud;
  double? get longitud => _longitud;
  bool get tieneUbicacion => _latitud != null && _longitud != null;
  bool get obteniendoUbicacion => _obteniendoUbicacion;
  String? get avisoUbicacion => _avisoUbicacion;

  /// Pide permiso y obtiene la ubicación actual del celular.
  /// Si algo falla, deja un aviso pero no bloquea el reporte.
  Future<void> obtenerUbicacion() async {
    _obteniendoUbicacion = true;
    _avisoUbicacion = null;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _avisoUbicacion = 'Activá la ubicación del celular';
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        _avisoUbicacion = 'Sin permiso de ubicación';
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
    } catch (e) {
      _avisoUbicacion = 'No se pudo obtener la ubicación';
    } finally {
      _obteniendoUbicacion = false;
      notifyListeners();
    }
  }

  // ---------- Lista de incidentes ----------

  List<Incidente> _incidentes = [];
  bool _cargando = false;
  String? _error;

  List<Incidente> get incidentes => _incidentes;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacio => _incidentes.isEmpty && !_cargando && _error == null;

  Future<void> cargarIncidentes() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _incidentes = await _servicio.obtenerTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Guarda un incidente nuevo. Devuelve true si salió bien.
  Future<bool> guardarIncidente({
    required String descripcion,
    required String calle,
  }) async {
    if (_seleccionados.isEmpty) {
      _error = 'Marcá al menos un tipo de incidente';
      notifyListeners();
      return false;
    }
    if (calle.trim().isEmpty) {
      _error = 'Completá la calle o intersección';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final incidente = Incidente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipos: List<String>.from(_seleccionados),
        descripcion: descripcion.trim(),
        calle: calle.trim(),
        fecha: DateTime.now().toIso8601String(),
        foto: _rutaFoto ?? '',
        latitud: _latitud,
        longitud: _longitud,
      );
      await _servicio.guardar(incidente);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> eliminarIncidente(String id) async {
    final respaldo = List<Incidente>.from(_incidentes);
    final eliminado = _incidentes.firstWhere((i) => i.id == id);
    _incidentes.removeWhere((i) => i.id == id);
    notifyListeners();
    try {
      await _servicio.eliminar(id);
      // Borra también el archivo de la foto, si tenía
      if (eliminado.foto.isNotEmpty) {
        final archivo = File(eliminado.foto);
        if (await archivo.exists()) await archivo.delete();
      }
    } catch (e) {
      _incidentes = respaldo;
      _error = e.toString();
      notifyListeners();
    }
  }

  void limpiarFormulario() {
    _seleccionados.clear();
    _rutaFoto = null;
    _latitud = null;
    _longitud = null;
    _avisoUbicacion = null;
    _error = null;
    notifyListeners();
  }
}