import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_snake/elementos/elementos.dart';
import 'package:flutter_snake/Utilidades/preferencias.dart';

enum FrutaTipo { manzana, fresa, poison }

class Fruta {
  int position;
  final FrutaTipo tipo;

  Fruta({required this.position, required this.tipo});

  /// Dibuja la fruta con su imagen según el tipo.
  Widget buildWidget(double cellSize) {
    String asset;
    switch (tipo) {
      case FrutaTipo.manzana:
        asset = 'assets/frutas/manzana.png';
        break;
      case FrutaTipo.fresa:
        asset = 'assets/frutas/fresa.png';
        break;
      case FrutaTipo.poison:
        asset = 'assets/frutas/poison.png';
        break;
    }
    return Image.asset(
      asset,
      width: cellSize,
      height: cellSize,
      fit: BoxFit.contain,
    );
  }

  /// Efecto al comerla.
  void applyEffect(Serpiente snake) {
    switch (tipo) {
      case FrutaTipo.manzana:
        snake.crecer(1);
        break;
      case FrutaTipo.fresa:
        snake.crecer(2);
        break;
      case FrutaTipo.poison:
        snake.encoger(1);
        break;
    }
  }

  /// Reposiciona esta fruta en una casilla libre.
  void reposicionar({
    required Set<int> ocupadas,
    required int filas,
    required int columnas,
  }) {
    final total = filas * columnas;
    int pos;
    do {
      pos = Random().nextInt(total);
    } while (ocupadas.contains(pos));
    position = pos;
  }
}