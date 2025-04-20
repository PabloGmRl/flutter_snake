import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_snake/elementos/elementos.dart';
import 'dart:async';

class RejillaSnake extends StatefulWidget {
  const RejillaSnake({super.key});

  @override
  State<RejillaSnake> createState() => _RejillaSnakeState();
}

class _RejillaSnakeState extends State<RejillaSnake> with SingleTickerProviderStateMixin{

  late final AnimationController _controller;
  late final Animation<double> _animation;

  List<int> _oldSegments = [];
  List<int> _newSegments = [];

  Direccion? direccionActual;
  // Ajusta aquí tu tamaño de rejilla
  static const int filas = 20;
  static const int columnas = 20;
  //el tamaño de la serpiente siempre es [ x , x+columnas] para que salga recta
  final snake = SnakeModel(filas: filas, columnas: columnas,initialSegments: [45, 65, 85],);
  int manzana = 123;
  SnakeSkin skin = ClassicSkin();

  Color obtenerColorCelda(int index) {
    if (index == manzana) return Colors.red;
    return Colors.grey[300]!; // fondo neutro
  }


  @override
  void initState() {
    super.initState();

    // Inicializamos segmentos
    _oldSegments = List.from(snake.segmentos);
    _newSegments = List.from(snake.segmentos);

    // 300ms para un paso completo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Usamos una animación lineal 0→1
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState((){}); // cada frame vuelves a pintar
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 1) Terminó la interpolación: avanzamos la serpiente
          _oldSegments = List.from(_newSegments);
          snake.avanzar();
          _newSegments = List.from(snake.segmentos);

          // 2) Reiniciamos la animación
          _controller.forward(from: 0.0);
        }
      });

    // Arrancamos el loop
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final mq   = MediaQuery.of(context);
    final hTot = mq.size.height;
    final wTot = mq.size.width;
    final paddingTop = mq.padding.top;
    final appBarH    = AppBar().preferredSize.height;

    // Altura “útil” sin status bar ni AppBar
    final hUtil = hTot - paddingTop - appBarH;

    // 70% para el grid, 30% para el control
    final hGridBox    = hUtil * 0.7;
    final hControlBox = hUtil * 0.3;

    // calculamos el tamaño máximo de celda que cabe SIN deformar:
    //   - para no salirse del alto asignado: hGridBox / filas
    //   - para no salirse del ancho: wTot / columnas
    final cellSize = min(hGridBox / filas, wTot / columnas);

    // dimensiones reales de la rejilla
    final gridH = cellSize * filas;
    final gridW = cellSize * columnas;

    return Scaffold(
      appBar: AppBar(title: const Text('Snake')),
      body: Column(
        children: [

          // ─── CAJA SUPERIOR (70%): dentro, centramos la rejilla ───
          SizedBox(
            height: hGridBox,
            width: wTot,
            child: Center(
              child: SizedBox(
                height: gridH,
                width: gridW,
                child: Stack(
                  children: [
                    // 1) Rejilla de fondo (manzana + vacío)
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filas * columnas,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: obtenerColorCelda(index),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),

                    // 2) Por encima, cada fragmento de la serpiente
                    for (int i = 0; i < _newSegments.length; i++)
                      Builder(builder: (context) {
                        // pos anterior
                        final oldIdx = _oldSegments.length > i
                            ? _oldSegments[i]
                            : _oldSegments.last; // si crece, repite la última

                        final newIdx = _newSegments[i];

                        final oldRow = oldIdx ~/ columnas;
                        final oldCol = oldIdx % columnas;
                        final newRow = newIdx ~/ columnas;
                        final newCol = newIdx % columnas;

                        // desplazamiento en píxels
                        final dx = (newCol - oldCol) * cellSize;
                        final dy = (newRow - oldRow) * cellSize;

                        // interpolación lineal
                        final left = oldCol * cellSize + dx * _animation.value;
                        final top  = oldRow * cellSize + dy * _animation.value;

                        return Positioned(
                          left: left,
                          top: top,
                          child: skin.buildSegment(
                            context,
                            index: newIdx,
                            cellSize: cellSize,
                            isHead: i == _newSegments.length - 1,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),

          GestureDetector(
            onPanUpdate: (d) {
              final dx = d.delta.dx;
              final dy = d.delta.dy;
              Direccion nueva = (dx.abs() > dy.abs())
                  ? (dx > 0 ? Direccion.derecha : Direccion.izquierda)
                  : (dy > 0 ? Direccion.abajo  : Direccion.arriba);

              setState(() {
                snake.cambiarDireccion(nueva);
              });
            },
            child: Container(
              height: hControlBox,
              width: wTot,
              color: Colors.blueGrey[900],
              child: Center(
                child: Text(
                  'Desliza para mover: ${direccionActual?.name ?? "ninguna"}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void cambiarDireccion(DragUpdateDetails d) {
    final dx = d.delta.dx;
    final dy = d.delta.dy;

    setState(() {
      if (dx.abs() > dy.abs()) {
        direccionActual = (dx > 0) ? Direccion.derecha : Direccion.izquierda;
      } else {
        direccionActual = (dy > 0) ? Direccion.abajo   : Direccion.arriba;
      }
    });
  }
}
