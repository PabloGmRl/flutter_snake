import 'package:flutter/material.dart';
import 'package:flutter_snake/Pantallas/rejilla_snake.dart';
import 'package:flutter_snake/Pantallas/mejores_partidas.dart';
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
          // IconButton de ajustes eliminado
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // — Botón JUGAR —
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final seen = prefs.getBool('seenSplash') ?? false;
                if (!seen) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const PantallaTutorial(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RejillaSnake()));
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.blue,
                elevation: 4,
              ),
              child: const Text(
                'JUGAR',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // — Botón TUTORIAL —
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const PantallaTutorial(desdePrincipal: true,),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.green,
                elevation: 4,
              ),
              child: const Text(
                'TUTORIAL',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // dentro de tu Column de botones
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AjustesPagina()),
                );
              },
              // resto del estilo idéntico
              child: const Text('AJUSTES'),
            ),
          ],
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
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
