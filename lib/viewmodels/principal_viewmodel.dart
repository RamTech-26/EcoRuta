import 'package:flutter/material.dart';

/// ViewModel de la pantalla principal.
/// Maneja los campos de origen y destino, y el panel deslizable inferior.
class PrincipalViewModel extends ChangeNotifier {
  final TextEditingController controladorBusqueda = TextEditingController();
  final TextEditingController controladorDestino = TextEditingController();

  final DraggableScrollableController controladorPanel =
      DraggableScrollableController();

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

  @override
  void dispose() {
    controladorBusqueda.dispose();
    controladorDestino.dispose();
    controladorPanel.dispose();
    super.dispose();
  }
}