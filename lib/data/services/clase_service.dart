import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/clase.dart';

class ClaseService {
  final Dio _dio = ApiClient().dio;

  Future<Clase> fetchClaseById(int idClase) async {
    final res = await _dio.get('/clase/$idClase');
    return Clase.fromJson(res.data as Map<String, dynamic>);
  }
}
