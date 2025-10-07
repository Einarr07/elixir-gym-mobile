import 'dart:convert';

import 'package:elixir_gym/data/models/schedule.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HorarioService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  Future<List<Horario>> fetchHorario() async {
    final response = await http.get(Uri.parse('$baseUrl/horario-clase/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Horario.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener los horarios");
    }
  }
}
