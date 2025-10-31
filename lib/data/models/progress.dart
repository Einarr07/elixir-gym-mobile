class Progress {
  final int idProgreso;
  final int idUsuario;
  final DateTime fecha;
  final double peso;
  final double? grasaCorporal;
  final String? observaciones;

  const Progress({
    required this.idProgreso,
    required this.idUsuario,
    required this.fecha,
    required this.peso,
    this.grasaCorporal,
    this.observaciones,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      idProgreso: json['idProgreso'] as int,
      idUsuario: json['idUsuario'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      peso: (json['peso'] as num).toDouble(),
      grasaCorporal: (json['grasa_corporal'] as num?)?.toDouble(),
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'idProgreso': idProgreso,
    'idUsuario': idUsuario,
    'fecha': _formatDate(fecha),
    'peso': peso,
    'grasa_corporal': grasaCorporal,
    'observaciones': observaciones,
  }..removeWhere((_, v) => v == null);

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
