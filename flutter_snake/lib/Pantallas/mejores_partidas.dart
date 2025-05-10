import 'package:flutter/material.dart';
import 'package:flutter_snake/Utilidades/almacenamiento_resultados.dart';


class MejoresPartidas extends StatefulWidget {
  const MejoresPartidas({super.key});

  @override
  State<MejoresPartidas> createState() => _MejoresPartidasState();
}

class _MejoresPartidasState extends State<MejoresPartidas> {
  late Future<List<int>> _topScores;

  @override
  void initState() {
    super.initState();
    _topScores = AlmacenamientoResultados.getTopScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mejores puntuaciones')),
      body: FutureBuilder<List<int>>(
        future: _topScores,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final scores = snapshot.data ?? [];
          if (scores.isEmpty) {
            return const Center(child: Text('Aún no hay puntuaciones.'));
          }
          return ListView.separated(
            itemCount: scores.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              return ListTile(
                leading: Text('#${i + 1}'),
                title: Text('${scores[i]} puntos'),
              );
            },
          );
        },
      ),
    );
  }
}