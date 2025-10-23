import 'package:elixir_gym/data/models/training.dart';
import 'package:elixir_gym/data/services/training_service.dart';
import 'package:flutter/foundation.dart';

class TrainerTrainingProvider extends ChangeNotifier {
  final TrainingService _service = TrainingService();

  List<Entrenamiento> trainings = [];
  bool isLoading = false;
  String? error;

  /// Cargar todos los entrenamientos
  Future<void> loadTrainings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      trainings = await _service.fetchAllTrainings();
    } catch (e) {
      error = 'Error al cargar los entrenamientos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Agregar un nuevo entrenamiento a la lista (opcional para reactividad inmediata)
  void addTraining(Entrenamiento training) {
    trainings.add(training);
    notifyListeners();
  }

  /// Eliminar un entrenamiento de la lista local
  void removeTraining(int idEntrenamiento) {
    trainings.removeWhere((t) => t.idEntrenamiento == idEntrenamiento);
    notifyListeners();
  }

  Future<Entrenamiento> createTraining({
    required String nombre,
    required String descripcion,
    required String nivel,
    required int semanasDeDuracion,
  }) async {
    try {
      final nuevo = await _service.createTraining(
        nombre: nombre,
        descripcion: descripcion,
        nivel: nivel,
        semanasDeDuracion: semanasDeDuracion,
      );
      trainings.add(nuevo);
      notifyListeners();
      return nuevo;
    } catch (e) {
      throw Exception('Error al crear entrenamiento: $e');
    }
  }

  Future<void> deleteTraining(int idEntrenamiento) async {
    try {
      await _service.deleteTraining(idEntrenamiento);
      removeTraining(idEntrenamiento);
    } catch (e) {
      throw Exception('Error al eliminar entrenamiento: $e');
    }
  }
}
