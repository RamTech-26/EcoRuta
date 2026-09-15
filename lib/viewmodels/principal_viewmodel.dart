import 'package:flutter/material.dart'; // necesita ChangeNotifier, controllers y DraggableScrollableController

class PrincipalViewModel extends ChangeNotifier {
  final TextEditingController controladorBusqueda = TextEditingController(); // campo "Buscar Destino"
  final TextEditingController controladorDestino = TextEditingController();  // campo "Destino"

  final DraggableScrollableController controladorPanel =
      DraggableScrollableController(); // controla el panel deslizable

  void alternarPanel() {                                    // abre o cierra el panel
    final abierto = controladorPanel.size > 0.2;            // ¿está abierto?
    controladorPanel.animateTo(
      abierto ? 0.1 : 0.35,                                 // si está abierto baja; si no, sube
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {                                          // libera recursos
    controladorBusqueda.dispose();                          // libera controller de búsqueda
    controladorDestino.dispose();                           // libera controller de destino
    controladorPanel.dispose();                             // libera controller del panel
    super.dispose();                                        // siempre al final
  }
}

/* Cambios clave (PantallaLogin):

ViewModel con controladorUsuario, controladorContrasena, estado logueado y métodos login() / loginConGoogle().

La Vista ya no navega directamente desde el botón Confirmar ni maneja la lógica de sesión.

La Vista solo lee el ViewModel (con ListenableBuilder) y llama a sus métodos.

La navegación a PantallaPrincipal ahora ocurre cuando logueado cambia a true dentro del ListenableBuilder (es reacción al estado, no al botón).

 */