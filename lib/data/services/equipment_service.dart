import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/equipment.dart';

class EquipmentService {
  EquipmentService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/equipo';

  Future<List<Equipment>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw Exception('Respuesta inesperada: se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('cargar equipos', e);
    }
  }

  Future<Equipment> fetchById(int idEquipo) async {
    try {
      final Response res = await _dio.get('$_base/$idEquipo');
      _ensureOk(res);
      return Equipment.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('cargar equipo $idEquipo', e);
    }
  }

  Future<Equipment> create({
    required String nombre,
    required String tipo,
    required String estado,
  }) async {
    final data = {'nombre': nombre, 'tipo': tipo, 'estado': estado};
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return Equipment.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('crear equipo', e);
    }
  }

  Future<void> update({
    required int idEquipo,
    required String nombre,
    required String tipo,
    required String estado,
  }) async {
    final data = {'nombre': nombre, 'tipo': tipo, 'estado': estado};
    try {
      final Response res = await _dio.put(
        '$_base/actualizar/$idEquipo',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('actualizar equipo $idEquipo', e);
    }
  }

  Future<void> delete(int idEquipo) async {
    try {
      final Response res = await _dio.delete('$_base/eliminar/$idEquipo');
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('eliminar equipo $idEquipo', e);
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
