class TrainingHistory {
  final int idHistorial;
  final int idEntrenamiento;
  final int idUsuario;
  final DateTime inicio;
  final DateTime? fin;
  final bool completado;

  TrainingHistory({
    required this.idHistorial,
    required this.idEntrenamiento,
    required this.idUsuario,
    required this.inicio,
    required this.fin,
    required this.completado,
  });

  factory TrainingHistory.fromJson(Map<String, dynamic> json) {
    return TrainingHistory(
      idHistorial: json['idHistorial'],
      idEntrenamiento: json['idEntrenamiento'],
      idUsuario: json['idUsuario'],
      inicio: json['inicio'],
      fin: json['fin'],
      completado: json['completado'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idHistorial': idHistorial,
    'idEntrenamiento': idEntrenamiento,
    'idUsuario': idUsuario,
    'inicio': inicio,
    'fin': fin,
    'completado': completado,
  };
}
