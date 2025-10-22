import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/clase.dart';

class ClaseService {
  final Dio _dio = ApiClient().dio;

  Future<List<Clase>> fetchAllClasses() async {
    final res = await _dio.get('/clase/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => Clase.fromJson(e)).toList();
  }

  Future<Clase> fetchClaseById(int idClase) async {
    final res = await _dio.get('/clase/$idClase');
    return Clase.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Clase> createClase({
    required String nombre,
    required String descripcion,
    required String dificultad,
    required int duracion,
    required int capacidadMax,
  }) async {
    final data = {
      "nombre": nombre,
      "descripcion": descripcion,
      "dificultad": dificultad,
      "duracion": duracion,
      "capacidad_max": capacidadMax,
    };

    try {
      final res = await _dio.post('/clase/crear', data: data);

      return Clase.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Error al crear la clase: ${e.response?.data ?? e.message} ',
      );
    }
  }
}
