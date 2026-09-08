import 'package:flutter/material.dart';
import 'vistas/pantalla_login.dart'; // ruta actualizada a la carpeta vistas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PantallaLogin(), // Pantalla Inicial
    );
  }
}