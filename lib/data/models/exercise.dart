import 'equipment.dart';
import 'muscle_group.dart';

class Exercise {
  final int idEjercicio;
  final String nombre;
  final String descripcion;
  final String? video;
  final String? imagen;
  final String equipoNecesario;
  final MuscleGroup grupoMuscular;
  final List<Equipment> equipos;

  Exercise({
    required this.idEjercicio,
    required this.nombre,
    required this.descripcion,
    required this.video,
    required this.imagen,
    required this.equipoNecesario,
    required this.grupoMuscular,
    required this.equipos,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      idEjercicio: json['idEjercicio'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      video: json['video'] as String?,
      imagen: json['imagen'] as String?,
      equipoNecesario: json['equipo_necesario'] as String,
      grupoMuscular: MuscleGroup.fromJson(
        json['grupo_muscular'] as Map<String, dynamic>,
      ),
      equipos: (json['equipos'] as List<dynamic>? ?? const [])
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'idEjercicio': idEjercicio,
    'nombre': nombre,
    'descripcion': descripcion,
    'video': video,
    'imagen': imagen,
    'equipo_necesario': equipoNecesario,
    'grupo_muscular': grupoMuscular.toJson(),
    'equipos': equipos.map((e) => e.toJson()).toList(),
  };
}
