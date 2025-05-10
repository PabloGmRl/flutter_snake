// snake_skin.dart

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_snake/elementos/elementos.dart';

abstract class SnakeSkin {
  /// Devuelve el widget que pintará el segmento en `index`.
  Widget buildSegment(BuildContext context, {
    required int index,
    required double cellSize,
    required bool isHead,
  });
}

/// Skin clásico: un cuadrado verde
class ClassicSkin extends SnakeSkin {
  @override
  Widget buildSegment(BuildContext context, {
    required int index,
    required double cellSize,
    required bool isHead,
  }) {
    return Container(
      width: cellSize,
      height: cellSize,
      color: isHead ? Colors.green[800] : Colors.green,
    );
  }
}

/// Skin “pixel art” con imagen de cabeza y cuerpo
class PixelArtSkin extends SnakeSkin {
  final Serpiente snake;
  PixelArtSkin(this.snake);

  @override
  Widget buildSegment(BuildContext context, {
    required int index,
    required double cellSize,
    required bool isHead,
  }) {
    final segmentos = snake.segmentos;

    // ─── 1) Cabeza ─────────────────────────────────────────────────────────────
    if (isHead) {
      return Image.asset(
        'assets/serpiente/cabeza_${snake.direccionActual.name}.png',
        width: cellSize, height: cellSize, fit: BoxFit.contain,
      );
    }

// ─── 2) Cola ──────────────────────────────────────────────────────────────
    final tailIndex = segmentos.first;
    if (index == tailIndex && segmentos.length > 1) {
      final next = segmentos[1];
      final dx = (next % snake.columnas) - (tailIndex % snake.columnas);
      final dy = (next ~/ snake.columnas) - (tailIndex ~/ snake.columnas);
      final tailDir = dx.abs() > dy.abs()
          ? (dx > 0 ? Direccion.derecha : Direccion.izquierda)
          : (dy > 0 ? Direccion.abajo : Direccion.arriba);
      return Image.asset(
        'assets/serpiente/cola_${tailDir.name}.png',
        width: cellSize, height: cellSize, fit: BoxFit.contain,
      );
    }

// ─── 3) Cuerpo ────────────────────────────────────────────────────────────
    final i = segmentos.indexOf(index);
    final prev = segmentos[i - 1];
    final next = segmentos[i + 1];

    Direccion dirPrev = _directionBetween(index, prev);
    Direccion dirNext = _directionBetween(index, next);

// Si está en línea recta horizontal
    if ((dirPrev == Direccion.izquierda && dirNext == Direccion.derecha) ||
        (dirPrev == Direccion.derecha && dirNext == Direccion.izquierda)) {
      return Image.asset(
        'assets/serpiente/cuerpo_arriba_abajo.png',
        width: cellSize, height: cellSize, fit: BoxFit.contain,
      );
    }

// Si está en línea recta vertical
    if ((dirPrev == Direccion.arriba && dirNext == Direccion.abajo) ||
        (dirPrev == Direccion.abajo && dirNext == Direccion.arriba)) {
      return Image.asset(
        'assets/serpiente/cuerpo_arriba_abajo.png',
        width: cellSize, height: cellSize, fit: BoxFit.contain,
      );
    }

// Fallback por si ocurre algo inesperado
    return Image.asset(
      'assets/serpiente/cuerpo_arriba_abajo.png',
      width: cellSize, height: cellSize, fit: BoxFit.contain,
    );
  }
  /// Devuelve la dirección de movimiento de `from` → `to`
  Direccion _directionBetween(int from, int to) {
    final df = to - from;
    if (df == 1) return Direccion.derecha;
    if (df == -1) return Direccion.izquierda;
    if (df == snake.columnas) return Direccion.abajo;
    return Direccion.arriba;
  }
}