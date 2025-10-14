import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/schedule.dart';

class HorarioService {
  final Dio _dio = ApiClient().dio;

  Future<List<Horario>> fetchHorarios() async {
    final res = await _dio.get('/horario-clase/todos');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => Horario.fromJson(e)).toList();
  }
}
