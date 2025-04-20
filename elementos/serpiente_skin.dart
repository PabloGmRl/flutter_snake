// snake_skin.dart

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  @override
  Widget buildSegment(BuildContext context, {
    required int index,
    required double cellSize,
    required bool isHead,
  }) {
    if (isHead) {
      return Image.asset('assets/snake_head.png', width: cellSize, height: cellSize);
    } else {
      return Image.asset('assets/snake_body.png', width: cellSize, height: cellSize);
    }
  }
}
