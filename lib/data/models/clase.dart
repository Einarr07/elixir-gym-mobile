class Clase {
  final int idClase;
  final String nombre;
  final String descripcion;
  final String? dificultad;
  final int duracion;
  final int? capacidadMax;

  Clase({
    required this.idClase,
    required this.nombre,
    required this.descripcion,
    this.dificultad,
    required this.duracion,
    this.capacidadMax,
  });

  factory Clase.fromJson(Map<String, dynamic> json) {
    return Clase(
      idClase: json['idClase'],
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      dificultad: json['dificultad'],
      duracion: json['duracion'] ?? 0,
      capacidadMax: json['capacidad_max'],
    );
  }
}
