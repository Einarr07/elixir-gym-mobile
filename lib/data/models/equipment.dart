class Equipment {
  final int idEquipo;
  final String nombre;
  final String tipo;
  final String estado;

  Equipment({
    required this.idEquipo,
    required this.nombre,
    required this.tipo,
    required this.estado,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      idEquipo: json['idEquipo'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'idEquipo': idEquipo,
    'nombre': nombre,
    'tipo': tipo,
    'estado': estado,
  };
}
