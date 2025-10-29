class TrainingExercise {
  final int idEntrenamiento;
  final int idEjercicio;
  final int series;
  final int repeticiones;
  final double pesoSugerido;
  final int descansoSegundos;

  TrainingExercise({
    required this.idEntrenamiento,
    required this.idEjercicio,
    required this.series,
    required this.repeticiones,
    required this.pesoSugerido,
    required this.descansoSegundos,
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      idEntrenamiento: json['idEntrenamiento'],
      idEjercicio: json['idEjercicio'],
      series: json['series'],
      repeticiones: json['repeticiones'],
      pesoSugerido: json['pesoSugerido'],
      descansoSegundos: json['descansoSegundos'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idEntrenamiento': idEntrenamiento,
    'idEjercicio': idEjercicio,
    'series': series,
    'repeticiones': repeticiones,
    'pesoSugerido': pesoSugerido,
    'descansoSegundos': descansoSegundos,
  };
}
