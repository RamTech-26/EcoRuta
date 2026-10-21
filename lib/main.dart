import 'package:alarm/alarm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'repositorios/auth_repositorio.dart';
import 'servicios/alarma_servicio.dart'; // <- AGREGADO
import 'servicios/auth_servicio.dart';
import 'servicios/usuario_servicio.dart';
import 'vistas/pantalla_login.dart';
import 'vistas/pantalla_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Alarm.init();
  AlarmaServicio.initListener(); // <- AGREGADO - FIX DEL STREAM
  await _precargarFuentes();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepositorio>(
          create: (_) => AuthRepositorio(
            authServicio: AuthServicio(),
            usuarioServicio: UsuarioServicio(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Precarga Poppins antes de mostrar la primera pantalla. Si no, algunos
/// widgets (como los chips) se miden con la fuente de reemplazo y después
/// el texto queda cortado cuando llega Poppins.
Future<void> _precargarFuentes() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.poppins(fontWeight: FontWeight.w500),
      GoogleFonts.poppins(fontWeight: FontWeight.w600),
      GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ]).timeout(const Duration(seconds: 3));
  } catch (_) {
    // Sin internet la primera vez: seguimos con la fuente por defecto.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseAuth.instance.currentUser != null
          ? const PantallaPrincipal()
          : const PantallaLogin(),
    );
  }
}
