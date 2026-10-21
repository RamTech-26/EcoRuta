import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../modelos/lugar_frecuente.dart';
import '../modelos/punto_ruta.dart';
import '../repositorios/ubicacion_repositorio.dart';
import '../servicios/ubicacion_servicio.dart';
import '../viewmodels/principal_viewmodel.dart';
import 'pantalla_alarmas.dart';
import 'pantalla_lista_lugares_frecuentes.dart';
import 'pantalla_login.dart';
import 'pantalla_puntos.dart';
import 'pantalla_reporte_incidente.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final PrincipalViewModel viewModel;

  /// Foco de cada campo, para poder abrir el teclado al elegir
  /// "Escribir una dirección".
  final Map<CampoRuta, FocusNode> _foco = {
    CampoRuta.origen: FocusNode(),
    CampoRuta.destino: FocusNode(),
  };

  /// Campos en los que el usuario eligió escribir a mano. Mientras no estén
  /// acá, tocar el campo abre el panel de opciones en vez del teclado.
  final Set<CampoRuta> _escribiendo = {};

  @override
  void initState() {
    super.initState();
    viewModel = PrincipalViewModel(
      ubicacionRepositorio: UbicacionRepositorioImpl(UbicacionServicio()),
    );
    viewModel.cargarLugares();
    for (final campo in CampoRuta.values) {
      final foco = _foco[campo]!;
      // Mientras no se esté escribiendo, el campo no toma el foco. Así no
      // queda con el borde verde cuando se cierra el panel de opciones.
      foco.canRequestFocus = false;
      foco.addListener(() {
        // Al salir del campo, vuelve a abrir las opciones la próxima vez.
        if (!foco.hasFocus && _escribiendo.remove(campo)) {
          foco.canRequestFocus = false;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    for (final foco in _foco.values) {
      foco.dispose();
    }
    viewModel.dispose();
    super.dispose();
  }

  // ---------- Origen y destino ----------

  Future<void> _abrirOpciones(CampoRuta campo) async {
    FocusScope.of(context).unfocus();
    final eleccion = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) =>
          _PanelOpcionesRuta(campo: campo, lugares: viewModel.lugares),
    );
    if (!mounted || eleccion == null) return;

    if (eleccion == _OpcionRuta.ubicacionActual) {
      await _usarUbicacionActual(campo);
    } else if (eleccion is LugarFrecuente) {
      viewModel.elegirLugar(campo, eleccion);
    } else if (eleccion == _OpcionRuta.escribir) {
      _empezarAEscribir(campo);
    }
  }

  void _empezarAEscribir(CampoRuta campo) {
    // Si había algo que no fue escrito a mano (GPS, lugar), lo borramos.
    final punto = viewModel.punto(campo);
    if (punto != null && punto.tipo != TipoPunto.manual) {
      viewModel.limpiar(campo);
    }
    setState(() => _escribiendo.add(campo));
    // Esperamos a que el campo deje de ser solo lectura para abrir el teclado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = viewModel.controlador(campo);
      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
      _foco[campo]!
        ..canRequestFocus = true
        ..requestFocus();
    });
  }

  Future<void> _usarUbicacionActual(CampoRuta campo) async {
    final estado = await viewModel.usarUbicacionActual(campo);
    if (!mounted) return;

    switch (estado) {
      case EstadoUbicacion.ok:
        break;
      case EstadoUbicacion.servicioApagado:
        final abrir = await _preguntar(
          titulo: 'Ubicación desactivada',
          texto:
              'Para usar tu ubicación actual, activá la ubicación '
              'del celular y después volvé a elegir "Mi ubicación actual".',
          boton: 'Activar',
        );
        if (abrir) await viewModel.abrirAjustesUbicacion();
      case EstadoUbicacion.sinPermisoPermanente:
        final abrir = await _preguntar(
          titulo: 'Permiso de ubicación',
          texto:
              'EcoRuta no tiene permiso para usar tu ubicación. '
              'Podés habilitarlo en los ajustes de la app.',
          boton: 'Abrir ajustes',
        );
        if (abrir) await viewModel.abrirAjustesApp();
      case EstadoUbicacion.sinPermiso:
        _avisar(
          'Sin permiso de ubicación. Podés elegir un lugar '
          'o escribir la dirección.',
        );
      case EstadoUbicacion.error:
        _avisar('No se pudo obtener la ubicación. Probá de nuevo.');
    }
  }

  Future<bool> _preguntar({
    required String titulo,
    required String texto,
    required String boton,
  }) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
            child: Text(boton),
          ),
        ],
      ),
    );
    return respuesta ?? false;
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget _campoRuta(CampoRuta campo) {
    final esOrigen = campo == CampoRuta.origen;
    final ctrl = viewModel.controlador(campo);
    final escribiendo = _escribiendo.contains(campo);
    final buscando = viewModel.buscandoUbicacion == campo;

    final Widget sufijo;
    if (buscando) {
      sufijo = const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (viewModel.punto(campo) != null) {
      sufijo = IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        tooltip: 'Borrar',
        onPressed: () => viewModel.limpiar(campo),
      );
    } else {
      sufijo = IconButton(
        icon: const Icon(Icons.expand_more, color: Color(0xFF0F766E)),
        tooltip: 'Opciones',
        onPressed: () => _abrirOpciones(campo),
      );
    }

    return TextField(
      controller: ctrl,
      focusNode: _foco[campo],
      readOnly: !escribiendo,
      showCursor: escribiendo,
      canRequestFocus: escribiendo,
      onTap: escribiendo || buscando ? null : () => _abrirOpciones(campo),
      // Tocar afuera cierra el teclado y vuelve al modo "opciones".
      onTapOutside: (_) => _foco[campo]!.unfocus(),
      decoration: InputDecoration(
        hintText: esOrigen ? 'Origen' : 'Destino',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          esOrigen ? Icons.my_location : Icons.location_on,
          color: const Color(0xFF0F766E),
        ),
        suffixIcon: sufijo,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2.5),
        ),
      ),
    );
  }

  Widget _baldosa(IconData icono, String titulo, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 36,
                color: const Color(0xFF0F766E),
              ), // <-- tu color
              const SizedBox(height: 8),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fila de chips con los lugares frecuentes para completar el destino.
  Widget _chipsLugares() {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.lugares.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.lugares.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final lugar = viewModel.lugares[i];
                final elegido = viewModel.destino?.lugarId == lugar.id;
                return ChoiceChip(
                  avatar: Text(lugar.emoji),
                  label: Text(lugar.nombre),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: elegido ? Colors.white : const Color(0xFF0F766E),
                  ),
                  selected: elegido,
                  showCheckmark: false,
                  selectedColor: const Color(0xFF0F766E),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) =>
                      viewModel.elegirLugar(CampoRuta.destino, lugar),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EcoRuta',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) => Column(
                    children: [
                      _campoRuta(CampoRuta.origen),
                      const SizedBox(height: 12),
                      _campoRuta(CampoRuta.destino),
                    ],
                  ),
                ),
                _chipsLugares(),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: viewModel.cerrarPanel,
                  child: Container(
                    color: Colors.grey[200],
                    child: const Center(child: Text('Mapa')),
                  ),
                ),
                DraggableScrollableSheet(
                  controller: viewModel.controladorPanel,
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  maxChildSize: 0.8,
                  snap: true,
                  snapSizes: const [0.1, 0.8],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          // Barrita de arrastre (color 0F766E)
                          GestureDetector(
                            onTap: viewModel.alternarPanel,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              alignment: Alignment.topCenter,
                              color: Colors.transparent,
                              child: Container(
                                width: 60,
                                height: 6,
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F766E,
                                  ), // <-- tu color
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),

                          // Grid de 4 baldosas
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: [
                              _baldosa(
                                Icons.warning_amber,
                                'Reportar Incidente',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PantallaReporteIncidente(),
                                    ),
                                  );
                                },
                              ),
                              _baldosa(Icons.home, 'Lugares Frecuentes', () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PantallaListaLugaresFrecuentes(),
                                  ),
                                );
                                // Al volver, refrescamos los chips por si
                                // se agregó, editó o borró algún lugar.
                                viewModel.cargarLugares();
                              }),
                              _baldosa(Icons.alarm, 'Alarmas', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaAlarmas(),
                                  ),
                                );
                              }),
                              _baldosa(Icons.stars, 'Mis Puntos', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaPuntos(),
                                  ),
                                );
                              }),
                            ],
                          ),

                          // Botón de cerrar sesión
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaLogin(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Cerrar sesión'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opciones fijas del panel (los lugares frecuentes se devuelven tal cual).
enum _OpcionRuta { ubicacionActual, escribir }

/// Panel que se abre al tocar Origen o Destino.
class _PanelOpcionesRuta extends StatelessWidget {
  final CampoRuta campo;
  final List<LugarFrecuente> lugares;

  const _PanelOpcionesRuta({required this.campo, required this.lugares});

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF0F766E);
    final titulo = campo == CampoRuta.origen
        ? '¿Desde dónde salís?'
        : '¿A dónde vas?';

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.my_location, color: verde),
              title: const Text('Mi ubicación actual'),
              subtitle: const Text('Usa el GPS del celular'),
              onTap: () => Navigator.pop(context, _OpcionRuta.ubicacionActual),
            ),
            if (lugares.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  'Lugares frecuentes',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              ...lugares.map((lugar) {
                final sinUbicacion = lugar.latitud == 0 && lugar.longitud == 0;
                return ListTile(
                  leading: Text(
                    lugar.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(lugar.nombre),
                  subtitle: Text(
                    sinUbicacion
                        ? '${lugar.direccion} · sin ubicación'
                        : lugar.direccion,
                  ),
                  onTap: () => Navigator.pop(context, lugar),
                );
              }),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: verde),
              title: const Text('Escribir una dirección'),
              onTap: () => Navigator.pop(context, _OpcionRuta.escribir),
            ),
            // Cuando el mapa esté listo: habilitar esta opción, abrir el mapa
            // y llamar a viewModel.asignarDesdeMapa(campo, ...) con el punto.
            const ListTile(
              enabled: false,
              leading: Icon(Icons.map),
              title: Text('Elegir en el mapa'),
              subtitle: Text('Disponible cuando esté el mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
