import 'package:flutter/material.dart';
import 'vistas/pantalla_login.dart';
import 'package:alarm/alarm.dart';
import 'servicios/alarma_servicio.dart'; // <- AGREGADO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  AlarmaServicio.initListener(); // <- AGREGADO - FIX DEL STREAM
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PantallaLogin(),
    );
  }
}