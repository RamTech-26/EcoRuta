import 'package:flutter/foundation.dart'; // solo necesita ChangeNotifier

class LoginViewModel extends ChangeNotifier {
  bool _logueado = false;                  // estado privado
  bool get logueado => _logueado;          // getter para leer

  void login(String usuario, String contrasena) {  // recibe credenciales
    if (usuario.isEmpty || contrasena.isEmpty) return; // validación mínima
    _logueado = true;                      // cambia el estado
    notifyListeners();                     // avisa a la vista
  }

  void loginConGoogle() {                  // sin parámetros
    _logueado = true;
    notifyListeners();
  }
}

/* Cambios clave (PantallaLogin — versión B):

ViewModel LoginViewModel con estado privado _logueado, getter público logueado, y métodos login(String usuario, String contrasena) y loginConGoogle() que terminan en notifyListeners().

La Vista maneja los TextEditingController (usuario y contraseña) y los libera en su dispose().

La Vista ya no navega directamente desde el botón Confirmar; solo llama a viewModel.login(usuario, contrasena).

La navegación a PantallaPrincipal ocurre cuando logueado cambia a true dentro del ListenableBuilder, usando pushReplacement.

El ViewModel no importa material.dart, solo foundation.dart, porque no depende de ningún widget.

 */