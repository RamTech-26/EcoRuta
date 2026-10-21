import 'package:flutter/material.dart';

import '../servicios/alarma_servicio.dart';
import '../viewmodels/alarma_viewmodel.dart';

/// Se asegura de que las alarmas puedan sonar antes de activar una.
///
/// Si falta el permiso, explica para qué sirve y lo pide solo si el
/// usuario acepta. Si se negó para siempre, ofrece abrir los ajustes.
/// Devuelve si el permiso quedó concedido.
Future<bool> asegurarPermisoAlarma(
  BuildContext context,
  AlarmaViewModel viewModel,
) async {
  final estado = await viewModel.revisarPermisos();
  if (estado == EstadoPermisoAlarma.concedido) return true;
  if (!context.mounted) return false;

  final negadoParaSiempre = estado == EstadoPermisoAlarma.negadoParaSiempre;
  final acepta = await showDialog<bool>(
    context: context,
    builder: (contextoDialogo) => AlertDialog(
      title: const Text('Permitir alarmas'),
      content: Text(
        negadoParaSiempre
            ? 'Para que la alarma suene, EcoRuta necesita permiso de alarmas '
                  'y notificaciones. Podés habilitarlo en los ajustes de la app '
                  'y después volver a activarla.'
            : 'Para que la alarma suene aunque tengas la app cerrada, EcoRuta '
                  'necesita permiso para programar alarmas y mostrar '
                  'notificaciones.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(contextoDialogo, false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(contextoDialogo, true),
          child: Text(negadoParaSiempre ? 'Abrir ajustes' : 'Permitir'),
        ),
      ],
    ),
  );
  if (acepta != true) return false;

  if (negadoParaSiempre) {
    await viewModel.abrirAjustes();
    return false;
  }
  return await viewModel.pedirPermisos() == EstadoPermisoAlarma.concedido;
}
