import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/training_exercise.dart';

class TrainingExerciseService {
  TrainingExerciseService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;
  static const _base = '/entrenamiento-ejercicio';

  Future<List<TrainingExercise>> fetchAll() async {
    try {
      final Response res = await _dio.get('$_base/todos');
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw Exception('Respuesta inesperada: Se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap('Cargar de todos entrenamiento-ejercicio', e);
    }
  }

  Future<List<TrainingExercise>> fetchAllTraining(int idEntrenamiento) async {
    try {
      final Response res = await _dio.get(
        '$_base/entrenamiento/$idEntrenamiento',
      );
      _ensureOk(res);
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Respuesta inesperada: Se esperaba una lista');
    } on DioException catch (e) {
      throw _wrap(
        'Cargar lista de ejercicios de 1 entrenamiento especifico',
        e,
      );
    }
  }

  Future<TrainingExercise> fetchById(
    int idEntrenamiento,
    int idEjercicio,
  ) async {
    try {
      final Response res = await _dio.get(
        '$_base/$idEntrenamiento/$idEjercicio',
      );
      _ensureOk(res);
      return TrainingExercise.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(
        'Cargar entrenamiento $idEntrenamiento y ejercicio $idEjercicio',
        e,
      );
    }
  }

  Future<TrainingExercise> create({
    required int idEntrenamiento,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    required double pesoSugerido,
    required int descansoSegundos,
  }) async {
    final data = {
      'idEntrenamiento': idEntrenamiento,
      'idEjercicio': idEjercicio,
      'series': series,
      'repeticiones': repeticiones,
      'peso_sugerido': pesoSugerido,
      'descanso_segundos': descansoSegundos,
    };
    try {
      final Response res = await _dio.post('$_base/crear', data: data);
      _ensureOk(res);
      return TrainingExercise.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap('Crear entrenamiento-ejercicio', e);
    }
  }

  Future<void> update({
    required int idEntrenamiento,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    required double pesoSugerido,
    required int descansoSegundos,
  }) async {
    final data = {
      'idEntrenamiento': idEntrenamiento,
      'idEjercicio': idEjercicio,
      'series': series,
      'repeticiones': repeticiones,
      'peso_sugerido': pesoSugerido,
      'descanso_segundos': descansoSegundos,
    };
    try {
      final Response res = await _dio.put(
        '$_base/actualizar/$idEntrenamiento/$idEjercicio',
        data: data,
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap(
        'Actualizar entrenamiento $idEntrenamiento y ejercicio $idEjercicio',
        e,
      );
    }
  }

  Future<void> delete(int idEntrenamiento, int idEjercicio) async {
    try {
      final Response res = await _dio.delete(
        '$_base/eliminar/$idEntrenamiento/$idEjercicio',
      );
      _ensureOk(res, allowNoContent: true);
    } on DioException catch (e) {
      throw _wrap(
        'Eliminar entrenamiento $idEntrenamiento y ejercicio $idEjercicio',
        e,
      );
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
