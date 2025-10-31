class MuscleGroup {
  final int idGrupoMuscular;
  final String? nombre;
  final String? descripcion;

  MuscleGroup({
    required this.idGrupoMuscular,
    required this.nombre,
    required this.descripcion,
  });

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      idGrupoMuscular: json['idGrupoMuscular'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idGrupoMusuclar': idGrupoMuscular,
    'nombre': nombre,
    'descripcion': descripcion,
  };
}
