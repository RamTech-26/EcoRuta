import 'package:flutter/material.dart'; // necesita ChangeNotifier y TextEditingController

class LoginViewModel extends ChangeNotifier {  // hereda la capacidad de avisar cambios
  final TextEditingController controladorUsuario = TextEditingController();      // campo usuario
  final TextEditingController controladorContrasena = TextEditingController();   // campo contraseña

  bool _logueado = false;                 // estado: ¿el usuario ya inició sesión?
  bool get logueado => _logueado;         // getter para que la Vista lo lea

  void login() {                          // acción del botón Confirmar
    _logueado = true;                     // marca como logueado
    notifyListeners();                    // avisa a la Vista que cambió
  }

  void loginConGoogle() {                 // acción del botón Google
    _logueado = true;                     // marca como logueado
    notifyListeners();                    // avisa a la Vista que cambió
  }

  @override
  void dispose() {                        // libera recursos
    controladorUsuario.dispose();         // libera el controller de usuario
    controladorContrasena.dispose();      // libera el controller de contraseña
    super.dispose();                      // siempre al final
  }
}

/* Cambios clave:

ViewModel con controladorBusqueda, controladorDestino, controladorPanel y alternarPanel().

La Vista ya no tiene DraggableScrollableController ni lógica de panel.

La Vista solo lee el ViewModel y llama a sus métodos.

La navegación a PantallaReporteIncidente sigue en la Vista (es decisión de UI, no de lógica). */