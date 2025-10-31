import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';

import '../models/training_history.dart';

class TrainingHistoryService {
  TrainingHistoryService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/historial-entrenameinto';

  Future<List<TrainingHistory>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => TrainingHistory.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw Exception('Respuesta inesperada: Se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('Cargar historial de entrenamiento', e);
    }
  }

  Future<TrainingHistory> fetchById(int idHistorial) async {
    try {
      final Response res = await _dio.get('$_base/$idHistorial');
      _ensureOk(res);
      return TrainingHistory.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Cargar historial de entrenamiento $idHistorial', e);
    }
  }

  Future<TrainingHistory> create({
    required int idEntrenamiento,
    required int idUsuario,
    required DateTime inicio,
    required DateTime? fin,
    required bool completado,
  }) async {
    final data = {
      'idEntrenamiento': idEntrenamiento,
      'idUsuario': idUsuario,
      'inicio': inicio,
      'fin': fin,
      'completado': completado,
    };
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return TrainingHistory.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Crear historial de entrenamiento', e);
    }
  }

  Future<void> update({
    required int idHistorial,
    required int idEntrenamiento,
    required int idUsuario,
    required DateTime inicio,
    required DateTime? fin,
    required bool completado,
  }) async {
    final data = {
      'idEntrenamiento': idEntrenamiento,
      'idUsuario': idUsuario,
      'inicio': inicio,
      'fin': fin,
      'completado': completado,
    };
    try {
      final Response res = await _dio.put(
        '$_base/actualizar/$idHistorial',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Actualizar historial de entrenamiento $idHistorial', e);
    }
  }

  Future<void> delete(int idHistorial) async {
    try {
      final Response res = await _dio.delete('$_base/eliminar/$idHistorial');
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Eliminar hitorial $idHistorial', e);
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
