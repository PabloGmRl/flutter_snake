import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_snake/elementos/elementos.dart';
import 'dart:async';
import 'package:flutter_snake/almacenamiento_resultados.dart';

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

  List<int> _segmentosIniciales = [];
  late int _longitudInicial;

  //Tamaño del mapa
  static const int filas = 20;
  static const int columnas = 20;
  //el tamaño de la serpiente siempre es [ x , x+columnas] para que salga recta
  final snake = Serpiente(filas: filas, columnas: columnas,initialSegments: [45, 65, 85],);
  late Fruta frutaActual;
  late SnakeSkin skin;
  bool _enPausa = false;


  @override
  void initState() {
    super.initState();
    skin = PixelArtSkin(snake);
    // Inicializamos segmentos
    _oldSegments = List.from(snake.segmentos);
    _newSegments = List.from(snake.segmentos);


    // 300ms para un paso completo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    frutaActual = Fruta.random(_eligePosicionAleatoria());

    _longitudInicial = snake.segmentos.length;
    _segmentosIniciales = snake.segmentos;
    // Usamos una animación lineal 0→1
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState((){}); // cada frame vuelves a pintar
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 1) Predigo la siguiente lista de segmentos
          final candNext = snake.proximoSegmentos();

          // 2) Si choco → Game Over sin mover la cabeza visualmente
          if (snake.colisionaEn(candNext.last)) {
            _controller.stop();
            _mostrarGameOver();
            return;
          }

          // 3) Commit del movimiento: actualizo old y new
          _oldSegments = List.from(_newSegments);
          snake.avanzar();                        // aplica candNext
          _newSegments = List.from(snake.segmentos);

          // 4) Chequeo “comer” fruta
          if (snake.segmentos.last == frutaActual.position) {
            frutaActual.applyEffect(snake);
            frutaActual = Fruta.random(_eligePosicionAleatoria());
            _newSegments = List.from(snake.segmentos);
          }

          // 5) Sigo animando
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
    DefaultAssetBundle.of(context)
        .loadString('AssetManifest.json')
        .then((s) => debugPrint(s));
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
      appBar: AppBar(
        leadingWidth: 140, // MÁS espacio reservado
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Align(
            alignment: Alignment.centerLeft, // Botón pegado a la izquierda
            child: SizedBox(
              width: 90,  // Botón más pequeño
              height: 42,  // Botón más delgadito
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text('Snake'),
        actions: [
          IconButton(
            icon: Icon(_enPausa ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePausa,
          ),
        ],
      ),






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
                        if (index == frutaActual.position) {
                          return frutaActual.buildWidget(cellSize);
                        } else {
                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }
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
                    //3) Cartel de pausa
                    if (_enPausa)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: const Text(
                            'En pausa',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          GestureDetector(
            onPanUpdate: cambiarDireccion,
            child: Container(
              height: hControlBox,
              width: wTot,
              color: Colors.blueGrey[900],
              child: Center(
                child: Text(
                  'Desliza para mover: ${snake.direccionActual.name}',
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
    final nueva = (dx.abs() > dy.abs())
        ? (dx > 0 ? Direccion.derecha : Direccion.izquierda)
        : (dy > 0 ? Direccion.abajo  : Direccion.arriba);

    setState(() {
      snake.cambiarDireccion(nueva);
    });
  }

  int _eligePosicionAleatoria() {
    final total = filas * columnas;
    int pos;
    do {
      pos = Random().nextInt(total);
    } while (snake.segmentos.contains(pos));
    return pos;
  }

  /// Muestra el diálogo de Game Over
  Future<void> _mostrarGameOver() async {
    final score = snake.segmentos.length - _longitudInicial;
    await AlmacenamientoResultados.addScore(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Puntuación: ${snake.segmentos.length - _longitudInicial}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();   // cierra el diálogo
              _reiniciarJuego();
            },
            child: const Text('Reiniciar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();   // cierra el diálogo
              Navigator.of(context).pop();   // vuelve al menú principal
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  /// Reinicia el estado completo para volver a jugar
  void _reiniciarJuego() {
    setState(() {
      // 1) Reset de la serpiente
      snake.reset(_segmentosIniciales);
      _oldSegments = List.from(snake.segmentos);
      _newSegments = List.from(snake.segmentos);

      // 2) Reset de fruta y puntuación
      frutaActual = Fruta.random(_eligePosicionAleatoria());
      _longitudInicial = snake.segmentos.length;

      // 3) Arrancar animación
      _controller.forward(from: 0.0);
    });
  }
  void _togglePausa() {
    setState(() {
      if (_enPausa) {
        _controller.forward();  // reanuda
      } else {
        _controller.stop(); //Para el juego
      }
      _enPausa = !_enPausa;
    });
  }
}