import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AlmacenamientoResultados {
  static const _fileName = 'high_scores.json';
  static const _maxScores = 20;

  /// Obtiene la ruta al fichero donde guardamos las puntuaciones.
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Lee y devuelve la lista de puntuaciones (orden descendente).
  static Future<List<int>> getTopScores() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final jsonStr = await file.readAsString();
      final List<dynamic> list = json.decode(jsonStr);
      return List<int>.from(list)..sort((b, a) => a.compareTo(b));
    } catch (_) {
      return [];
    }
  }

  /// Añade una nueva puntuación y guarda solo las top 20.
  static Future<void> addScore(int score) async {
    final scores = await getTopScores();
    scores.add(score);
    scores.sort((b, a) => a.compareTo(b));
    final trimmed = scores.take(_maxScores).toList();
    final file = await _getFile();
    await file.writeAsString(json.encode(trimmed));
  }
}