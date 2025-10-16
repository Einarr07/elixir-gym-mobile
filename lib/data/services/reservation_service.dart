// lib/data/services/reservation_service.dart
import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/reservation.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:intl/intl.dart';

class ReservaService {
  final Dio _dio = ApiClient().dio;

  /// Crea una reserva CONFIRMADA para el usuario en el horario dado
  Future<Reserva> crearReserva({
    required int idUsuario,
    required Horario horario,
  }) async {
    final payload = {
      "usuario": {"idUsuario": idUsuario},
      "horario": {"idHorario": horario.idHorario},
      // el API trabaja con formato yyyy-MM-dd
      "reservacion": DateFormat('yyyy-MM-dd').format(horario.fecha),
      "estado": "confirmada",
    };

    // Nota: ApiClient suele prefixear '/api'; por eso el path es relativo a '/api'
    final res = await _dio.post('/clase-reservada/crear', data: payload);
    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }

  /// Obtiene las reservas del usuario autenticado (endpoint nuevo)
  /// GET /api/clase-reservada/mis-reservas/{idUsuario}
  Future<List<Reserva>> obtenerReservas(int idUsuario) async {
    final res = await _dio.get('/clase-reservada/mis-reservas/$idUsuario');

    final data = res.data;
    final list = (data is List)
        ? data
        : (data is Map<String, dynamic> && data['data'] is List)
        ? data['data']
        : throw Exception('Formato inesperado: $data');

    return (list as List)
        .cast<Map<String, dynamic>>()
        .map((e) => Reserva.fromJson(e))
        .toList();
  }

  /// Actualiza SOLO el estado de una reserva
  /// PUT /api/clase-reservada/actualizar/{idReserva}
  /// Body: { "estado": "pendiente" | "confirmada" | "cancelada" | "completa" | "no asistio" | "expirada" }
  Future<Reserva> actualizarEstadoReserva({
    required Reserva reserva,
    required String estado,
  }) async {
    final payload = {
      "usuario": {"idUsuario": reserva.idUsuario},
      "horario": {"idHorario": reserva.idHorario},
      // Debe ir en yyyy-MM-dd (tu modelo ya lo tiene así)
      "reservacion": reserva.reservacion,
      "estado": estado,
    };

    final res = await _dio.put(
      '/clase-reservada/actualizar/${reserva.idReserva}',
      data: payload,
    );

    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }
}
