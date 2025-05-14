import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_snake/Utilidades/snake_app.dart';
import 'package:flutter_snake/Pantallas/snake_pagina_principal.dart';
import 'package:flutter_snake/Pantallas/Pantallas.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seenSplash') ?? false;
  runApp(MyApp(showSplash: !seen));
}

class MyApp extends StatelessWidget {
  final bool showSplash;
  const MyApp({super.key, required this.showSplash});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Snake',
      theme: ThemeData( colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent), useMaterial3: true ),
      home: showSplash ? const PantallaTutorial() : const SnakePaginaPrincipal(titulo: 'Snake'),
    );
  }
}
