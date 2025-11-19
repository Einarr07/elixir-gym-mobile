import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/schedule.dart';

class ScheduleService {
  ScheduleService({Dio? dio}) : _dio = dio ?? ApiClient().dio;
  final Dio _dio;
  static const _base = '/horario-clase';

  Future<List<Schedule>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
            .toList(growable: true);
      }
      throw Exception('Repuesta inesperada: Se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('Cargar todos los horarios', e);
    }
  }

  Future<Schedule> fetchById(int idHorario) async {
    try {
      final Response res = await _dio.get('$_base/$idHorario');
      _ensureOk(res);
      return Schedule.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Cargar horario $idHorario', e);
    }
  }

  Future<Schedule> create({
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required int idClase,
    required int idUsuarioEntrenador,
  }) async {
    final data = {
      // Formato "YYYY-MM-DD"
      'fecha': fecha.toIso8601String().split('T').first,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'clase': {'idClase': idClase},
      'entrenador': {'idUsuario': idUsuarioEntrenador},
    };
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return Schedule.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Crear horario', e);
    }
  }

  Future<void> update({
    required int idHorario, // Se usa en la URL
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required int idClase,
    required int idUsuarioEntrenador,
  }) async {
    final data = {
      'fecha': fecha.toIso8601String().split('T').first,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'clase': {'idClase': idClase},
      'entrenador': {'idUsuario': idUsuarioEntrenador},
    };
    try {
      // ¡ERROR CORREGIDO! Faltaba pasar 'data: data'
      final Response res = await _dio.put(
        '$_base/actualizar/$idHorario',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Actualizar horario $idHorario', e);
    }
  }

  // --- FIN DE CORRECCIONES ---

  Future<void> delete(int idHorario) async {
    try {
      final Response res = await _dio.delete('$_base/eliminar/$idHorario');
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Eliminar horario $idHorario', e);
    }
  }

  // ----------------- Helpers -----------------
  void _ensureOk(Response res, {bool allowNoContent = false}) {
    final code = res.statusCode ?? 0;
    final ok = code >= 200 && code < 300;
    if (!ok) throw Exception('HTTP $code: ${res.data}');
    if (allowNoContent && code == 204) return;
  }

  Exception _wrap(String accion, DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    return Exception('Error al $accion (HTTP $code): ${body ?? e.message}');
  }
}
