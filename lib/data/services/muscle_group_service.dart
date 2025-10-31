import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/muscle_group.dart';

class MuscleGroupService {
  MuscleGroupService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = "/grupo-muscular";

  Future<List<MuscleGroup>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => MuscleGroup.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw Exception('Respuesta inesperada: se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('Cargar grupos musculares', e);
    }
  }

  Future<MuscleGroup> fetchById(int idGrupoMuscular) async {
    try {
      final Response res = await _dio.get('$_base/$idGrupoMuscular');
      _ensureOk(res);
      return MuscleGroup.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Cargar grupo muscular $idGrupoMuscular', e);
    }
  }

  Future<MuscleGroup> create({required nombre, required descripcion}) async {
    final data = {'nombre': nombre, 'descripcion': descripcion};
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return MuscleGroup.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Crear grupo muscular', e);
    }
  }

  Future<void> update({
    required int idGrupoMuscular,
    required String nombre,
    required String descripcion,
  }) async {
    final data = {'nombre': nombre, 'descripcion': descripcion};
    try {
      final Response res = await _dio.put(
        '$_base/actualizar/$idGrupoMuscular',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Actualizar grupo muscular $idGrupoMuscular', e);
    }
  }

  Future<void> delete(int idGrupoMuscular) async {
    try {
      final Response res = await _dio.delete(
        '$_base/eliminar/$idGrupoMuscular',
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap('Eliminar grupo muscular', e);
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
