import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';

import '../models/exercise.dart';

class ExerciseService {
  ExerciseService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/ejercicio';

  // --------- READ ---------

  Future<List<Exercise>> fetchAll() async {
    try {
      final res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Respuesta inesperada: se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('cargar ejercicios', e);
    }
  }

  Future<Exercise> fetchById(int idEjercicio) async {
    try {
      final res = await _dio.get('$_base/$idEjercicio');
      _ensureOk(res);
      return Exercise.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('cargar ejercicio', e);
    }
  }

  // --------- CREATE ---------

  Future<Exercise> create({
    required String nombre,
    String? descripcion,
    String? video,
    String? imagen,
    String? equipoNecesario,
    required int idGrupoMuscular,
    required List<int> idsEquipos,
  }) async {
    final data = _buildBody(
      nombre: nombre,
      descripcion: descripcion,
      video: video,
      imagen: imagen,
      equipoNecesario: equipoNecesario,
      idGrupoMuscular: idGrupoMuscular,
      idsEquipos: idsEquipos,
    );
    try {
      final res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res); // admite 200/201
      return Exercise.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('crear ejercicio', e);
    }
  }

  // --------- UPDATE ---------

  Future<void> update({
    required int idEjercicio,
    required String nombre,
    String? descripcion,
    String? video,
    String? imagen,
    String? equipoNecesario,
    required int idGrupoMuscular,
    required List<int> idsEquipos,
  }) async {
    final data = _buildBody(
      nombre: nombre,
      descripcion: descripcion,
      video: video,
      imagen: imagen,
      equipoNecesario: equipoNecesario,
      idGrupoMuscular: idGrupoMuscular,
      idsEquipos: idsEquipos,
    );
    try {
      final res = await _dio.put('$_base/actualizar/$idEjercicio', data: data);
      _ensureOk(res, allowNoContent: true); // acepta 200/204
    } on DioException catch (e) {
      throw _wrap('actualizar ejercicio $idEjercicio', e);
    }
  }

  // --------- DELETE ---------

  Future<void> delete(int idEjercicio) async {
    try {
      final res = await _dio.delete('$_base/eliminar/$idEjercicio');
      _ensureOk(res, allowNoContent: true); // 204 OK
    } on DioException catch (e) {
      throw _wrap('eliminar ejercicio $idEjercicio', e);
    }
  }

  // --------- Helpers internos ---------

  Map<String, dynamic> _buildBody({
    required String nombre,
    String? descripcion,
    String? video,
    String? imagen,
    String? equipoNecesario,
    required int idGrupoMuscular,
    required List<int> idsEquipos,
  }) {
    final map = <String, dynamic>{
      'nombre': nombre,
      'descripcion': descripcion,
      'video': video,
      'imagen': imagen,
      'equipo_necesario': equipoNecesario,
      'grupo_muscular': {'idGrupoMuscular': idGrupoMuscular},
      'equipos': idsEquipos.map((id) => {'idEquipo': id}).toList(),
    };

    map.removeWhere((_, v) => v == null);
    return map;
  }

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
