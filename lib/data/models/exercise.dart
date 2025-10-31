// lib/data/models/exercise.dart

import 'equipment.dart';
import 'muscle_group.dart';

class Exercise {
  // --- CAMPOS ---
  // La mayoría son opcionales (`?`) porque al crear un ejercicio, no los tienes todos.
  final int? idEjercicio;
  final String nombre; // El nombre sí es obligatorio para crear.
  final String? descripcion;
  final String? video;
  final String? imagen;
  final String? equipoNecesario;

  // Guardamos tanto el ID (para enviar a la API) como el objeto (para mostrar en la UI).
  final int? idGrupoMuscular;
  final MuscleGroup? grupoMuscular;

  // Hacemos lo mismo para los equipos. Guardamos los IDs para enviarlos.
  final List<int>? equiposIds;
  final List<Equipment>? equipos;

  // --- CONSTRUCTOR ---
  // Ahora el constructor es flexible. Solo el `nombre` es realmente requerido.
  Exercise({
    required this.nombre,
    this.idEjercicio,
    this.descripcion,
    this.video,
    this.imagen,
    this.equipoNecesario,
    this.idGrupoMuscular,
    this.grupoMuscular,
    this.equiposIds,
    this.equipos,
  });

  // --- MÉTODO fromJson ---
  // Este método convierte la respuesta de la API en un objeto Exercise.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      idEjercicio: json['idEjercicio'],
      nombre: json['nombre'] ?? 'Sin nombre',
      // Usamos un valor por defecto por seguridad.
      descripcion: json['descripcion'],
      video: json['video'],
      imagen: json['imagen'],
      // Extraemos el ID del objeto anidado que viene en el JSON.
      idGrupoMuscular: json['grupo_muscular']?['idGrupoMuscular'],
      grupoMuscular: json['grupo_muscular'] != null
          ? MuscleGroup.fromJson(json['grupo_muscular'])
          : null,
      // Hacemos lo mismo para los equipos: extraemos los objetos completos.
      equipos: (json['equipos'] as List<dynamic>?)
          ?.map((e) => Equipment.fromJson(e))
          .toList(),
      // Y también extraemos solo los IDs, que son útiles para las actualizaciones.
      equiposIds: (json['equipos'] as List<dynamic>?)
          ?.map<int>((item) => item['idEquipo'] as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'video': video,
      // Añadido por si quieres enviarlo también
      'imagen': imagen,
      // Añadido por si quieres enviarlo también
      'equipo_necesario': equipoNecesario,

      // Crea un objeto anidado para el grupo muscular, como en Postman.
      'grupo_muscular': {'idGrupoMuscular': idGrupoMuscular},

      // Convierte la lista de IDs [1, 2] en una lista de objetos [{idEquipo: 1}, {idEquipo: 2}].
      'equipos': equiposIds?.map((id) => {'idEquipo': id}).toList(),
    };
  }
}
