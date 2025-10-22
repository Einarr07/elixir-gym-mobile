import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class TrainerClaseProvider extends ChangeNotifier {
  final ClaseService _service = ClaseService();
  List<Clase> clases = [];
  bool isLoading = false;
  String? error;

  Future<void> loadClases() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      clases = await _service.fetchAllClasses();
    } catch (e) {
      error = 'Error al cargar las clases: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
