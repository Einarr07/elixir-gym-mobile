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
      // el API muestra "2026-10-02" => usar yyyy-MM-dd
      "reservacion": DateFormat('yyyy-MM-dd').format(horario.fecha),
      "estado": "confirmada",
    };

    final res = await _dio.post('/clase-reservada/crear', data: payload);

    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }

  /// Obtiene las reservas de un usuario
  Future<List<Reserva>> obtenerReservas(int idUsuario) async {
    final res = await _dio.get('/clase-reservada/usuario/$idUsuario');

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
}
