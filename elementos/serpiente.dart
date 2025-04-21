// snake_model.dart

enum Direccion { arriba, abajo, izquierda, derecha }

class Serpiente {
  final int filas;
  final int columnas;

  List<int> _segmentos; // índices 0D de cada célula
  Direccion direccionActual;
  int _pendienteDeCrecer = 0;//Contador para crecer

  Serpiente({
    required this.filas,
    required this.columnas,
    List<int>? initialSegments,
    this.direccionActual = Direccion.derecha,
  }) : _segmentos = initialSegments ?? [0, 1, 2];

  List<int> get segmentos => List.unmodifiable(_segmentos);

  /// ④ Avanza realmente el modelo (ya sin más comprobaciones)
  void avanzar() {
    final crecer = _pendienteDeCrecer > 0;//Si el contador es mayor que 0 debe crecer
    final next = proximoSegmentos(crecer: crecer);
    _segmentos = next;
    if (_pendienteDeCrecer > 0) _pendienteDeCrecer--;//Se descuenta porque ya ha crecido(va de 1 en 1)
  }


  /// ⑤ Impide giros de 180°
  void cambiarDireccion(Direccion nueva) {
    final opuesto = (direccionActual == Direccion.arriba    && nueva == Direccion.abajo)
        || (direccionActual == Direccion.abajo    && nueva == Direccion.arriba)
        || (direccionActual == Direccion.izquierda&& nueva == Direccion.derecha)
        || (direccionActual == Direccion.derecha  && nueva == Direccion.izquierda);
    if (opuesto) return;
    direccionActual = nueva;
  }

  /// ③ Comprueba si colisionarías en esa posición
  bool colisionaEn(int posicion) {
    // contra el cuerpo
    if (_segmentos.contains(posicion)) return true;
    // contra top/bottom
    if (posicion < 0 || posicion >= filas * columnas) return true;
    // wrap lateral: venías de x última col y ahora estás en col 0, o viceversa
    final col = posicion % columnas;
    if (direccionActual == Direccion.derecha && col == 0) return true;
    if (direccionActual == Direccion.izquierda && col == columnas - 1) return true;
    return false;
  }

  void reset([List<int>? initialSegments]) {
    _segmentos = initialSegments ?? [0, 1, 2];
    direccionActual = Direccion.derecha;
  }

  /// ① Calcula la posición que tendría la cabeza al avanzar
  int siguienteCabeza() {
    final cabeza = _segmentos.last;
    switch (direccionActual) {
      case Direccion.arriba:    return cabeza - columnas;
      case Direccion.abajo:     return cabeza + columnas;
      case Direccion.izquierda: return cabeza - 1;
      case Direccion.derecha:   return cabeza + 1;
    }
  }

  /// ② Predice la nueva lista de segmentos tras avanzar (sin mutar)
  List<int> proximoSegmentos({ bool crecer = false }) {
    final next = List<int>.from(_segmentos);
    next.add(siguienteCabeza());
    if (!crecer) next.removeAt(0);
    return next;
  }
  void crecer(int cantidad) {
    _pendienteDeCrecer += cantidad;
  }
}