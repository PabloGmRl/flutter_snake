import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_snake/snake_pagina_principal.dart'; // ajusta la ruta si hace falta

class PantallaTutorial extends StatefulWidget {
  final bool desdePrincipal;
  const PantallaTutorial({Key? key,this.desdePrincipal=false}) : super(key: key);

  @override
  State<PantallaTutorial> createState() => _PantallaTutorialState();
}

class _PantallaTutorialState extends State<PantallaTutorial> {
  final PageController _controller = PageController();
  int _paginaActual = 0;

  final List<_TutorialPage> _pages = [
    _TutorialPage(
      image: 'assets/tutorial/welcome.png',
      title: '¡Bienvenido a Flutter Snake!',
      description: 'Desliza para descubrir los modos de juego y sus reglas.',
    ),
    _TutorialPage(
      image: 'assets/tutorial/muy_facil.png',
      title: 'Modo Muy Fácil',
      description: '¡Sin muros! Cruza los bordes y reaparecerás al otro lado.',
    ),
    _TutorialPage(
      image: 'assets/tutorial/facil.png',
      title: 'Modo Fácil',
      description: 'Juego clásico: muros sólidos, velocidad constante.',
    ),
    _TutorialPage(
      image: 'assets/tutorial/normal.png',
      title: 'Modo Normal',
      description: 'La velocidad aumenta cada vez que comes fruta.',
    ),
    _TutorialPage(
      image: 'assets/tutorial/dificil.png',
      title: 'Modo Difícil',
      description: 'Como Normal, más 3 frutas poison que encogen la serpiente.',
    ),
  ];

  Future<void> _onStartPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenSplash', true);
    if(!widget.desdePrincipal) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SnakePaginaPrincipal(
            titulo: 'Flutter Snake')),
      );
    }else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (context, i) {
              final page = _pages[i];
              return Container(
                width: double.infinity,
                height: double.infinity,
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
                      if (page.image != null)
                        Image.asset(
                          page.image!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(height: 24),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Indicador de páginas
          Positioned(
            bottom: 100,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _paginaActual == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _paginaActual == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Botón “Comenzar” en la última página
          if (_paginaActual == _pages.length - 1)
            Positioned(
              bottom: 32,
              left: 0, right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _onStartPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TutorialPage {
  final String? image;
  final String title;
  final String description;
  _TutorialPage({this.image, required this.title, required this.description});
}