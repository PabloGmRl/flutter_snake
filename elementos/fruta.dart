import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_snake/elementos/elementos.dart';

enum FrutaTipo {
  manzana,
  fresa,
  // nueva fruta => añadir aquí
}

class Fruta {

  final int position;
  final FrutaTipo tipo;

  Fruta({required this.position, required this.tipo});

  Widget buildWidget(double cellSize) {
    switch (tipo) {
      case FrutaTipo.manzana:
        return Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case FrutaTipo.fresa:
        return Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(2),
          ),
        );
    // si añades más frutas, otro case aquí
    }
  }

  /// Efecto cuando la come la serpiente
  void applyEffect(Serpiente snake) {
    switch (tipo) {
      case FrutaTipo.manzana:
        snake.crecer(1);
        break;
        //Crece dos veces
      case FrutaTipo.fresa:
        snake.crecer(2);
        break;
    }
    //Más efectos en futuros case
  }



  static Fruta random(int position) {
    final tipos = FrutaTipo.values;
    final rnd = Random().nextInt(tipos.length);
    return Fruta(position: position, tipo: tipos[rnd]);
  }
}