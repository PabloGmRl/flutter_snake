// snake_model.dart

enum Direccion { arriba, abajo, izquierda, derecha }

class Serpiente {
  final int filas;
  final int columnas;

  List<int> _segmentos;
  Direccion direccionActual;
  Direccion? _direccionPendiente; // 🔥 dirección a aplicar cuando toque
  int _pendienteDeCrecer = 0;

  Serpiente({
    required this.filas,
    required this.columnas,
    List<int>? initialSegments,
    this.direccionActual = Direccion.derecha,
  }) : _segmentos = initialSegments ?? [0, 1, 2];

  List<int> get segmentos => List.unmodifiable(_segmentos);

  void avanzar() {
    //Antes de movernos: si hay dirección pendiente, la aplicamos
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

    //Si no es opuesto, la guardamos para aplicar al avanzar
    _direccionPendiente = nueva;
  }

  bool colisionaEn(int posicion) {
    if (_segmentos.contains(posicion)) return true;
    if (posicion < 0 || posicion >= filas * columnas) return true;
    final col = posicion % columnas;
    if (direccionActual == Direccion.derecha && col == 0) return true;
    if (direccionActual == Direccion.izquierda && col == columnas - 1) return true;
    return false;
  }

  void reset([List<int>? initialSegments]) {
    _segmentos = initialSegments ?? [0, 1, 2];
    direccionActual = Direccion.derecha;
    _direccionPendiente = null;
  }

  int siguienteCabeza() {
    final cabeza = _segmentos.last;
    switch (direccionActual) {
      case Direccion.arriba:    return cabeza - columnas;
      case Direccion.abajo:     return cabeza + columnas;
      case Direccion.izquierda: return cabeza - 1;
      case Direccion.derecha:   return cabeza + 1;
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
}
