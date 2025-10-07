import 'dart:convert';

import 'package:elixir_gym/data/models/clase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClaseService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  Future<List<Clase>> fetchClases() async {
    final response = await http.get(Uri.parse('$baseUrl/clase/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('🧩 Respuesta API: ${response.body}');
      return data.map((json) => Clase.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las clases');
    }
  }
}
