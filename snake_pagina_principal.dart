import 'package:flutter/material.dart';
import 'package:flutter_snake/Pantallas/rejilla_snake.dart';
import 'package:flutter_snake/mejores_partidas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_snake/Pantallas/Pantallas.dart';

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
        title: Text(widget.titulo,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MejoresPartidas()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (_) => _buildSettingsSheet(context),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final seen = prefs.getBool('seenSplash') ?? false;

            if (!seen) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PantallaTutorial(),
                  transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                ),
              );
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RejillaSnake()));
            }
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
  Widget _buildSettingsSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Ver tutorial de nuevo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PantallaTutorial(),
                  transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
