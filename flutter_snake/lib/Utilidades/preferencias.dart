import 'package:shared_preferences/shared_preferences.dart';

enum Dificultad { muyFacil, facil, normal, dificil }

class Preferencias {
  static const _keyDificultad = 'dificultad';

  /// Guarda la dificultad seleccionada en SharedPreferences.
  static Future<void> setDificultad(Dificultad d) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDificultad, d.index);
  }

  /// Recupera la dificultad (por defecto Fácil).
  static Future<Dificultad> getDificultad() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_keyDificultad) ?? Dificultad.facil.index;
    return Dificultad.values[idx];
  }
}