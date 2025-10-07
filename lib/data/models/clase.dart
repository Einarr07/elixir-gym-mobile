class Clase {
  final int id;
  final String nombre;
  final String descripcion;
  final String? dificultad;
  final int duracion;
  final int? capacidadMax;

  Clase({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.dificultad,
    required this.duracion,
    this.capacidadMax,
  });

  factory Clase.fromJson(Map<String, dynamic> json) {
    return Clase(
      id: json['idClase'],
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      dificultad: json['dificultad'],
      // puede venir null
      duracion: json['duracion'] ?? 0,
      capacidadMax: json['capacidad_max'], // puede venir null
    );
  }
}
