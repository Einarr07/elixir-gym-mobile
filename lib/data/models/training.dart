class Entrenamiento {
  final int idEntrenamiento;
  final String nombre;
  final String descripcion;
  final String nivel;
  final int semanasDeDuracion;

  Entrenamiento({
    required this.idEntrenamiento,
    required this.nombre,
    required this.descripcion,
    required this.nivel,
    required this.semanasDeDuracion,
  });

  factory Entrenamiento.fromJson(Map<String, dynamic> json) {
    return Entrenamiento(
      idEntrenamiento: json['idEntrenamiento'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      nivel: json['nivel'],
      semanasDeDuracion: json['semanas_de_duracion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEntrenamiento': idEntrenamiento,
      'nombre': nombre,
      'descripcion': descripcion,
      'nivel': nivel,
      'semanas_de_duracion': semanasDeDuracion,
    };
  }
}
