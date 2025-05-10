import 'package:flutter/material.dart';
import 'package:flutter_snake/Pantallas/snake_pagina_principal.dart';
import 'package:provider/provider.dart';

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Flutter Snake',
        theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.greenAccent,
    ),
          useMaterial3: true,
        ),
    home: const SnakePaginaPrincipal(titulo: 'Snake'),
    );
  }
}

