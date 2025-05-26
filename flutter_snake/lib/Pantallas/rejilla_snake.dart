import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_snake/elementos/elementos.dart';
import 'dart:async';
import 'package:flutter_snake/Utilidades/almacenamiento_resultados.dart';
import 'package:flutter_snake/Utilidades/preferencias.dart';
import 'package:flutter_snake/Utilidades/audio_manager.dart';

class RejillaSnake extends StatefulWidget {
  const RejillaSnake({Key? key}) : super(key: key);

  @override
  State<RejillaSnake> createState() => _RejillaSnakeState();
}

class _RejillaSnakeState extends State<RejillaSnake> with SingleTickerProviderStateMixin {
  static const int filas = 20, columnas = 20;

  late Serpiente snake;
  late AnimationController _controller;
  late Animation<double> _animation;

  late Dificultad _dificultad;
  List<Fruta> manzanas = [];
  List<Fruta> fresas   = [];
  List<Fruta> poisons  = [];

  List<int> _oldSegments = [];
  List<int> _newSegments = [];

  int _longitudInicial = 3;
  List<int> _segmentosIniciales = [];

  bool _enPausa = false;

  late Duration _duracionInicial; // 🔹 NUEVO

  @override
  void initState() {
    super.initState();
    // 1) cargo dificultad
    Preferencias.getDificultad().then((d) {
      setState(() => _dificultad = d);
      // 2) inicializo serpiente y wrap según modo
      snake = Serpiente(filas: filas, columnas: columnas, initialSegments: [45, 65, 85]);
      snake.setWrapMode(_dificultad == Dificultad.muyFacil);
      // 3) preparo frutas
      _finalizarFrutas();
      // 4) animación
      _initAnimation();
    });
  }

  void _initAnimation() {
    _duracionInicial = const Duration(milliseconds: 300); // 🔹 Guardamos duración inicial
    _controller = AnimationController(vsync: this, duration: _duracionInicial);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;

        // 1) Aplica la dirección pendiente
        snake.aplicarDireccionPendiente();

        // 2) Predecir próxima cabeza y comprobar colisión “game over”
        final nextHead = snake.siguienteCabeza();
        if (snake.colisionaEn(nextHead)) {
          _controller.stop();
          _mostrarGameOver();
          return;
        }

        // 3) Avanzamos la serpiente y guardamos los segmentos anteriores
        _oldSegments = List.from(_newSegments);
        snake.avanzar();
        _newSegments = List.from(snake.segmentos);

        // Comprobamos victoria
        final totalCeldas = filas * columnas;
        if (snake.segmentos.length == totalCeldas) {
          // toca sonido de victoria y abre diálogo
          AudioManager.playWinSound();
          _controller.stop();
          _mostrarVictoria();
          return;
        }

        // 4) AHORA sí miramos si la cabeza ha comido fruta
        final cabeza = snake.segmentos.last;
        for (final f in [...manzanas, ...fresas, ...poisons]) {
          if (f.position == cabeza) {
            try {
              f.applyEffect(snake);
              AudioManager.playEatSound();
              final diferencia = _oldSegments.length - snake.segmentos.length;
              if (diferencia > 0) {
                // Recorta también los segmentos anteriores desde la cabeza (para que la serpiente encoja)
                _oldSegments = _oldSegments.sublist(diferencia);
              }
              _newSegments = List.from(snake.segmentos);
              _onFruitEaten();

              // Actualiza newSegments para que se vea que encoge
              _newSegments = List.from(snake.segmentos);
            } on SnakeDiedException {
              _controller.stop();
              _mostrarGameOver();
              return;
            }

            // Reposiciona la fruta
            final ocupadas = {
              ...snake.segmentos,
              ...manzanas.map((e) => e.position),
              ...fresas.map((e) => e.position),
              ...poisons.map((e) => e.position),
            };
            f.reposicionar(ocupadas: ocupadas, filas: filas, columnas: columnas);
          }
        }

        // 5) Finalmente, lanzamos el siguiente paso de la animación
        _controller.forward(from: 0.0);
      });

    // Segmentos iniciales
    _oldSegments = List.from(snake.segmentos);
    _newSegments = List.from(snake.segmentos);
    _longitudInicial = snake.segmentos.length;
    _segmentosIniciales = snake.segmentos;
    _controller.forward();
  }

  /// Inicializa listas de frutas según dificultad.
  void _finalizarFrutas() {
    final ocupadas = snake.segmentos.toSet();

    int nManz, nFres, nPois;
    switch (_dificultad) {
      case Dificultad.muyFacil:
        nManz = 4; nFres = 3; nPois = 0; break;
      case Dificultad.facil:
        nManz = 3; nFres = 2; nPois = 0; break;
      case Dificultad.normal:
        nManz = 2; nFres = 2; nPois = 0; break;
      case Dificultad.dificil:
        nManz = 2; nFres = 1; nPois = 3; break;
    }

    manzanas = List.generate(nManz, (_) {
      final pos = _eligePosicionAleatoria(excluidas: ocupadas);
      ocupadas.add(pos);
      return Fruta(position: pos, tipo: FrutaTipo.manzana);
    });
    fresas = List.generate(nFres, (_) {
      final pos = _eligePosicionAleatoria(excluidas: ocupadas);
      ocupadas.add(pos);
      return Fruta(position: pos, tipo: FrutaTipo.fresa);
    });
    poisons = List.generate(nPois, (_) {
      final pos = _eligePosicionAleatoria(excluidas: ocupadas);
      ocupadas.add(pos);
      return Fruta(position: pos, tipo: FrutaTipo.poison);
    });
  }

  int _eligePosicionAleatoria({ required Set<int> excluidas }) {
    final total = filas * columnas;
    int pos;
    do {
      pos = Random().nextInt(total);
    } while (excluidas.contains(pos));
    return pos;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hUtil = mq.size.height - mq.padding.top - AppBar().preferredSize.height;
    final hGridBox = hUtil * 0.7;
    final wTot = mq.size.width;
    final cellSize = min(hGridBox / filas, wTot / columnas);
    final gridH = cellSize * filas, gridW = cellSize * columnas;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 90,
              height: 42,
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
          Padding(
            padding: const EdgeInsets.only(right: 80.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 42,
                height: 42,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  onPressed: _onPausePressed,
                  child: Icon(
                    _enPausa ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: hGridBox,
            width: wTot,
            child: Center(
              child: SizedBox(
                height: gridH, width: gridW,
                child: Stack(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filas * columnas,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas, childAspectRatio: 1
                      ),
                      itemBuilder: (context, index) {
                        // frutas
                        for (final f in manzanas) if (index == f.position) return f.buildWidget(cellSize);
                        for (final f in fresas)   if (index == f.position) return f.buildWidget(cellSize);
                        for (final f in poisons)  if (index == f.position) return f.buildWidget(cellSize);
                        // fondo
                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                    // serpiente
                    for (int i = 0; i < _newSegments.length; i++)
                      Builder(builder: (_) {
                        final oldIdx = i < _oldSegments.length ? _oldSegments[i] : _oldSegments.last;
                        final newIdx = _newSegments[i];
                        final oldRow = oldIdx ~/ columnas, oldCol = oldIdx % columnas;
                        final newRow = newIdx ~/ columnas, newCol = newIdx % columnas;
                        final dx = (newCol - oldCol) * cellSize;
                        final dy = (newRow - oldRow) * cellSize;
                        final left = oldCol * cellSize + dx * _animation.value;
                        final top  = oldRow * cellSize + dy * _animation.value;
                        final isHead = i == _newSegments.length - 1;
                        return Positioned(
                          left: left, top: top,
                          child: PixelArtSkin(snake).buildSegment(
                              context, index: newIdx, cellSize: cellSize, isHead: isHead
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onPanUpdate: _cambiarDireccion,
            child: Container(
              height: hUtil * 0.3,
              width: wTot,
              color: Colors.blueGrey[900],
              child: Center(
                child: Text(
                  'Desliza para mover',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPausePressed() {
    _controller.stop();
    setState(() => _enPausa = true);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Juego en Pausa'),
        content: const Text('¿Qué quieres hacer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _enPausa = false);
              _controller.forward();
            },
            child: const Text('Reanudar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reiniciarJuego();
            },
            child: const Text('Reiniciar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _onFruitEaten() {
    if (_dificultad == Dificultad.normal || _dificultad == Dificultad.dificil) {
      final newMs = (_controller.duration!.inMilliseconds - 10).clamp(100, 300);
      _controller.duration = Duration(milliseconds: newMs);
    }
  }

  void _reiniciarJuego() {
    snake.reset(_segmentosIniciales);
    snake.setWrapMode(_dificultad == Dificultad.muyFacil);
    _oldSegments = List.from(snake.segmentos);
    _newSegments = List.from(snake.segmentos);
    _longitudInicial = snake.segmentos.length;
    _finalizarFrutas();
    _controller.duration = _duracionInicial; // 🔹 Restauramos velocidad inicial
    _controller.forward(from: 0.0);
    setState(() => _enPausa = false);
  }

  Future<void> _mostrarGameOver() async {
    AudioManager.playLoseSound();
    final score = snake.segmentos.length;
    await AlmacenamientoResultados.addScore(score);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Puntuación: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reiniciarJuego();
            },
            child: const Text('Reiniciar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _cambiarDireccion(DragUpdateDetails d) {
    final dx = d.delta.dx, dy = d.delta.dy;
    final nueva = (dx.abs() > dy.abs())
        ? (dx > 0 ? Direccion.derecha : Direccion.izquierda)
        : (dy > 0 ? Direccion.abajo   : Direccion.arriba);
    setState(() => snake.cambiarDireccion(nueva));
    AudioManager.playMoveSound();
  }

  void _mostrarVictoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Victoria!'),
        content: const Text('Has llenado todo el tablero.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reiniciarJuego();
            },
            child: const Text('Reiniciar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}