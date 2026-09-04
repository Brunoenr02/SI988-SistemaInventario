import 'package:flutter/material.dart';
import 'features/inventario/presentation/views/inventario_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SITRA-Luz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const InventarioView(), // Pantalla principal cambiada
    );
  }
}
