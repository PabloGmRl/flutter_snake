import 'package:flutter/material.dart';
import 'package:flutter_snake/rejilla_snake.dart';

class SnakePaginaPrincipal extends StatefulWidget {
  final String titulo;
  const SnakePaginaPrincipal({super.key,required this.titulo});

  @override
  State<SnakePaginaPrincipal> createState() => _SnakePaginaPrincipalState();
}

class _SnakePaginaPrincipalState extends State<SnakePaginaPrincipal> {
  @override
  Widget build(BuildContext context,) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary,),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
// 9
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return RejillaSnake();
                },
              ),
            );
          },

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
            backgroundColor: Colors.blue, // Color de fondo
            elevation: 4, // Sombra
          ),
          child: const Text(
            'JUGAR',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
