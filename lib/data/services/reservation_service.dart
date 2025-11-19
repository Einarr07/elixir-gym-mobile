// lib/data/services/reservation_service.dart
import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/reservation_class.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:intl/intl.dart';

class ReservaService {
  final Dio _dio = ApiClient().dio;

  /// Crea una Reserva CONFIRMADA para el usuario en el horario dado
  Future<ReservationClass> crearReserva({
    required int idUsuario,
    required Schedule horario,
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
    return ReservationClass.fromJson(res.data as Map<String, dynamic>);
  }

  /// Obtiene las reservas del usuario autenticado (endpoint nuevo)
  /// GET /api/clase-reservada/mis-reservas/{idUsuario}
  Future<List<ReservationClass>> obtenerReservas(int idUsuario) async {
    final res = await _dio.get('/clase-reservada/mis-reservas/$idUsuario');

    final data = res.data;
    final list = (data is List)
        ? data
        : (data is Map<String, dynamic> && data['data'] is List)
        ? data['data']
        : throw Exception('Formato inesperado: $data');

    return (list as List)
        .cast<Map<String, dynamic>>()
        .map((e) => ReservationClass.fromJson(e))
        .toList();
  }

  /// Actualiza SOLO el estado de una ReservationClass
  /// PUT /api/clase-reservada/actualizar/{idReserva}
  /// Body: { "estado": "pendiente" | "confirmada" | "cancelada" | "completa" | "no asistio" | "expirada" }
  Future<ReservationClass> actualizarEstadoReserva({
    required ReservationClass reservaClass,
    required String estado,
  }) async {
    final payload = {
      "usuario": {"idUsuario": reservaClass.idUsuario},
      "horario": {"idHorario": reservaClass.idHorario},
      // Debe ir en yyyy-MM-dd (tu modelo ya lo tiene así)
      "reservacion": reservaClass.reservacion,
      "estado": estado,
    };

    final res = await _dio.put(
      '/clase-reservada/actualizar/${reservaClass.idReserva}',
      data: payload,
    );

    return ReservationClass.fromJson(res.data as Map<String, dynamic>);
  }
}
