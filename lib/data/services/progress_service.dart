import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/progress.dart';

class ProgressService {
  ProgressService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/progreso';

  Future<List<Progress>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Progress.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw Exception('Respuesta inesperada: Se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('Cargar todos los progresos', e);
    }
  }

  Future<Progress> fetchById(int idProgreso) async {
    try {
      final Response res = await _dio.get('$_base/$idProgreso');
      _ensureOk(res);
      return Progress.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Cargar progreso $idProgreso', e);
    }
  }

  Future<Progress> create({
    required int idProgreso,
    required int idUsuario,
    required DateTime fecha,
    required double peso,
    required double? grasaCorporal,
    required String? observaciones,
  }) async {
    final data = {
      'idProgreso': idProgreso,
      'idUsuario': idUsuario,
      'fecha': fecha,
      'peso': peso,
      'grasaCorporal': grasaCorporal,
      'observaciones': observaciones,
    };
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return Progress.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Crear progreso', e);
    }
  }

  Future<void> update({
    required int idProgreso,
    required int idUsuario,
    required DateTime fecha,
    required double peso,
    required double? grasaCorporal,
    required String? observaciones,
  }) async {
    final data = {
      'idProgreso': idProgreso,
      'idUsuario': idUsuario,
      'fecha': fecha,
      'peso': peso,
      'grasaCorporal': grasaCorporal,
      'observaciones': observaciones,
    };
    try {
      final Response res = await _dio.put(
        '$_base/actualizar/$idProgreso',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Actualizar progreso $idProgreso', e);
    }
  }

  Future<void> delete(int idProgreso) async {
    try {
      final Response res = await _dio.delete('$_base/eliminar/$idProgreso');
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Eliminar progreso $idProgreso', e);
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
