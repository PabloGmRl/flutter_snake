// snake_model.dart

enum Direccion { arriba, abajo, izquierda, derecha }

class SnakeDiedException implements Exception {
  String toString() => 'La serpiente ha muerto: tamaño insuficiente.';
}

class Serpiente {
  final int filas;
  final int columnas;

  List<int> _segmentos;
  Direccion direccionActual;
  Direccion? _direccionPendiente;
  int _pendienteDeCrecer = 0;
  bool wrapMode = false;  // activa/desactiva wrap-around

  Serpiente({
    required this.filas,
    required this.columnas,
    List<int>? initialSegments,
    this.direccionActual = Direccion.derecha,
  }) : _segmentos = initialSegments ?? [0, 1, 2];

  List<int> get segmentos => List.unmodifiable(_segmentos);

  /// Activa o desactiva el wrap-around.
  void setWrapMode(bool wrap) {
    wrapMode = wrap;
  }

  void avanzar() {
    if (_direccionPendiente != null) {
      direccionActual = _direccionPendiente!;
      _direccionPendiente = null;
    }
    final crecer = _pendienteDeCrecer > 0;
    final next = proximoSegmentos(crecer: crecer);
    _segmentos = next;
    if (_pendienteDeCrecer > 0) _pendienteDeCrecer--;
  }

  void cambiarDireccion(Direccion nueva) {
    final opuesto = (direccionActual == Direccion.arriba    && nueva == Direccion.abajo)
        || (direccionActual == Direccion.abajo     && nueva == Direccion.arriba)
        || (direccionActual == Direccion.izquierda && nueva == Direccion.derecha)
        || (direccionActual == Direccion.derecha   && nueva == Direccion.izquierda);
    if (opuesto) return;
    _direccionPendiente = nueva;
  }

  bool colisionaEn(int posicion) {
    if (wrapMode) return false;
    if (_segmentos.contains(posicion)) return true;
    if (posicion < 0 || posicion >= filas * columnas) return true;
    final col = posicion % columnas;
    if (direccionActual == Direccion.derecha && col == 0) return true;
    if (direccionActual == Direccion.izquierda && col == columnas - 1) return true;
    return false;
  }

  int siguienteCabeza() {
    final cabeza = _segmentos.last;
    int raw;
    switch (direccionActual) {
      case Direccion.arriba:    raw = cabeza - columnas; break;
      case Direccion.abajo:     raw = cabeza + columnas; break;
      case Direccion.izquierda: raw = cabeza - 1;       break;
      case Direccion.derecha:   raw = cabeza + 1;       break;
    }
    if (!wrapMode) return raw;

    // Wrap-around:
    final row = cabeza ~/ columnas;
    final col = cabeza % columnas;
    switch (direccionActual) {
      case Direccion.arriba:
        return ((row - 1 + filas) % filas) * columnas + col;
      case Direccion.abajo:
        return ((row + 1) % filas) * columnas + col;
      case Direccion.izquierda:
        return row * columnas + ((col - 1 + columnas) % columnas);
      case Direccion.derecha:
        return row * columnas + ((col + 1) % columnas);
    }
  }

  List<int> proximoSegmentos({ bool crecer = false }) {
    final next = List<int>.from(_segmentos);
    next.add(siguienteCabeza());
    if (!crecer) next.removeAt(0);
    return next;
  }

  void crecer(int cantidad) {
    _pendienteDeCrecer += cantidad;
  }

  void aplicarDireccionPendiente() {
    if (_direccionPendiente != null) {
      direccionActual = _direccionPendiente!;
      _direccionPendiente = null;
    }
  }

  void reset([List<int>? initialSegments]) {
    _segmentos = initialSegments ?? [0, 1, 2];
    direccionActual = Direccion.derecha;
    _direccionPendiente = null;
    wrapMode = false;
    _pendienteDeCrecer = 0;
  }

  void encoger(int cantidad) {
    for (int i = 0; i < cantidad; i++) {
      if (_segmentos.length > 1) {
        _segmentos.removeAt(0);
      } else {
        // Serpiente no puede encoger más, ha perdido
        throw SnakeDiedException(); // Lanza excepción personalizada
      }
    }
  }

}
