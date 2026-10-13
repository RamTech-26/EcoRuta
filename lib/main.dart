import 'package:flutter/material.dart';
import 'vistas/pantalla_login.dart';
import 'vistas/pantalla_principal.dart';
import 'package:alarm/alarm.dart';
import 'servicios/alarma_servicio.dart'; // <- AGREGADO
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Alarm.init();
  AlarmaServicio.initListener(); // <- AGREGADO - FIX DEL STREAM
  runApp(const MyApp());
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