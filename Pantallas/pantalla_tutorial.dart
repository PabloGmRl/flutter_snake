import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_snake/snake_pagina_principal.dart'; // ajusta la ruta si hace falta

class PantallaTutorial extends StatelessWidget {
  const PantallaTutorial({super.key});

  Future<void> _onStartPressed(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenSplash', true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Puedes poner aquí tu logo en un AppBar transparente o en el body
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono grande
              Icon(Icons.android, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                '🐍 Flutter Snake 🐍',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const Text(
                  'Instrucciones:\n'
                      '- Desliza para mover la serpiente.\n'
                      '- Come frutas para crecer.\n'
                      '- Evita chocar contra paredes o tu cuerpo.\n\n'
                      '¡Buena suerte!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _onStartPressed(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}