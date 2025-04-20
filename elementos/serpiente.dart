// snake_model.dart

enum Direccion { arriba, abajo, izquierda, derecha }

class SnakeModel {
  final int filas;
  final int columnas;

  List<int> _segmentos;     // índices 0D de cada célula
  Direccion direccionActual;

  SnakeModel({
    required this.filas,
    required this.columnas,
    List<int>? initialSegments,
    this.direccionActual = Direccion.derecha,
  }) : _segmentos = initialSegments ?? [0, 1, 2];

  List<int> get segmentos => List.unmodifiable(_segmentos);

  /// Mueve la serpiente en su dirección actual.
  void avanzar({ bool crecer = false }) {
    int cabeza = _segmentos.last;
    int nuevaCabeza;
    switch (direccionActual) {
      case Direccion.arriba:
        nuevaCabeza = cabeza - columnas;
        break;
      case Direccion.abajo:
        nuevaCabeza = cabeza + columnas;
        break;
      case Direccion.izquierda:
        nuevaCabeza = cabeza - 1;
        break;
      case Direccion.derecha:
        nuevaCabeza = cabeza + 1;
        break;
    }
    _segmentos.add(nuevaCabeza);
    if (!crecer) {
      _segmentos.removeAt(0);
    }
  }

  void cambiarDireccion(Direccion dir) {
    // opcional: impedir 180° directo
    direccionActual = dir;
  }

  bool colisiona() {
    final cabeza = _segmentos.last;
    // colisión con el propio cuerpo
    return _segmentos.sublist(0, _segmentos.length - 1).contains(cabeza)
        // o con bordes
        || cabeza < 0
        || cabeza >= filas * columnas;
  }

  void reset([List<int>? initialSegments]) {
    _segmentos = initialSegments ?? [0, 1, 2];
    direccionActual = Direccion.derecha;
  }
}