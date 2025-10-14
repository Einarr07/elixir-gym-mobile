// lib/data/models/reservation.dart
class Reserva {
  final int idReserva;
  final int idUsuario;
  final int idHorario;
  final String reservacion; // yyyy-MM-dd
  final String estado;

  // extras opcionales para pintar
  final String? nombreClase;
  final String? entrenador;
  final DateTime? fecha;
  final String? horaInicio;
  final String? horaFin;

  Reserva({
    required this.idReserva,
    required this.idUsuario,
    required this.idHorario,
    required this.reservacion,
    required this.estado,
    this.nombreClase,
    this.entrenador,
    this.fecha,
    this.horaInicio,
    this.horaFin,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final horario = (json['horario'] as Map?)?.cast<String, dynamic>();
    final clase = (horario?['clase'] as Map?)?.cast<String, dynamic>();
    final ent = (horario?['entrenador'] as Map?)?.cast<String, dynamic>();
    final fechaStr = horario?['fecha'] as String?;

    return Reserva(
      idReserva: json['idReserva'] ?? 0,
      idUsuario: (json['usuario']?['idUsuario']) ?? 0,
      idHorario: (horario?['idHorario']) ?? 0,
      reservacion: json['reservacion'] ?? '',
      estado: json['estado'] ?? '',
      nombreClase: clase?['nombre'],
      entrenador: (ent == null) ? null : '${ent['nombre']} ${ent['apellido']}',
      fecha: (fechaStr != null) ? DateTime.parse(fechaStr) : null,
      horaInicio: horario?['hora_inicio'] ?? horario?['horaInicio'],
      horaFin: horario?['hora_fin'] ?? horario?['horaFin'],
    );
  }

  Map<String, dynamic> toJson() => {
    "usuario": {"idUsuario": idUsuario},
    "horario": {"idHorario": idHorario},
    "reservacion": reservacion,
    "estado": estado,
  };
}
