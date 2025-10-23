import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/training.dart';

class TrainingService {
  final Dio _dio = ApiClient().dio;

  Future<List<Entrenamiento>> fetchAllTrainings() async {
    final res = await _dio.get('/entrenamientos/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => Entrenamiento.fromJson(e)).toList();
  }

  Future<Entrenamiento> featchTrainingById(int idEntrenamiento) async {
    final res = await _dio.get('/entrenamientos/$idEntrenamiento');
    return Entrenamiento.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Entrenamiento> createTraining({
    required String nombre,
    required String descripcion,
    required String nivel,
    required int semanasDeDuracion,
  }) async {
    final data = {
      "nombre": nombre,
      "descripcion": descripcion,
      "nivel": nivel,
      "semanas_de_duracion": semanasDeDuracion,
    };
    try {
      final res = await _dio.post('/entrenamientos/crear', data: data);
      return Entrenamiento.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Error al crear entrenamiento: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> updateTraining({
    required int idEntrenamiento,
    required String nombre,
    required String descripcion,
    required String nivel,
    required int semanasDeDuracion,
  }) async {
    final data = {
      "idEntrenamiento": idEntrenamiento,
      "nombre": nombre,
      "descripcion": descripcion,
      "nivel": nivel,
      "semanas_de_duracion": semanasDeDuracion,
    };

    try {
      final res = await _dio.put(
        '/entrenamientos/actualizar/$idEntrenamiento',
        data: data,
      );
    } on DioException catch (e) {
      throw Exception(
        'Error al actualizar entrenamiento: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> deleteTraining(int idEntrenamiento) async {
    try {
      await _dio.delete('/entrenamientos/eliminar/$idEntrenamiento');
    } on DioException catch (e) {
      throw Exception(
        'Error al eliminar entrenamiento: ${e.response?.data ?? e.message}',
      );
    }
  }
}
