
import 'package:flutter/widgets.dart';

class PrincipalViewModel extends ChangeNotifier {
  final TextEditingController controladorBusqueda = TextEditingController();
  final TextEditingController controladorDestino = TextEditingController();
  final DraggableScrollableController controladorPanel = DraggableScrollableController();

  void alternarPanel() {
    if (!controladorPanel.isAttached) return; // evita crash si aún no se montó
    final abierto = controladorPanel.size > 0.2;
    controladorPanel.animateTo(
      abierto ? 0.1 : 0.35,
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