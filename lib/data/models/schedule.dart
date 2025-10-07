import 'clase.dart';

class Horario {
  final int idHorario;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final Clase clase;
  final Entrenador entrenador;

  Horario({
    required this.idHorario,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.clase,
    required this.entrenador,
  });

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
    idHorario: json['idHorario'],
    fecha: DateTime.parse(json['fecha']),
    horaInicio: json['hora_inicio'],
    horaFin: json['hora_fin'],
    clase: Clase.fromJson(json['clase']),
    entrenador: Entrenador.fromJson(json['entrenador']),
  );
}

class Entrenador {
  final int idUsuario;
  final String nombre;
  final String apellido;

  Entrenador({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
  });

  factory Entrenador.fromJson(Map<String, dynamic> json) => Entrenador(
    idUsuario: json['idUsuario'],
    nombre: json['nombre'],
    apellido: json['apellido'],
  );
}
