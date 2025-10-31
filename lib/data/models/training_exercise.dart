class TrainingExercise {
  final int idEntrenamiento;
  final int idEjercicio;
  final String? nombre;
  final int series;
  final int repeticiones;
  final double pesoSugerido;
  final int descansoSegundos;

  TrainingExercise({
    required this.idEntrenamiento,
    required this.idEjercicio,
    this.nombre,
    required this.series,
    required this.repeticiones,
    required this.pesoSugerido,
    required this.descansoSegundos,
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      idEntrenamiento: json['idEntrenamiento'],
      idEjercicio: json['idEjercicio'],
      nombre: json['nombre'],
      series: json['series'],
      repeticiones: json['repeticiones'],
      pesoSugerido: (json['peso_sugerido'] as num).toDouble(),
      descansoSegundos: json['descanso_segundos'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idEntrenamiento': idEntrenamiento,
    'idEjercicio': idEjercicio,
    'nombre': nombre,
    'series': series,
    'repeticiones': repeticiones,
    'peso_sugerido': pesoSugerido,
    'descanso_segundos': descansoSegundos,
  };
}
