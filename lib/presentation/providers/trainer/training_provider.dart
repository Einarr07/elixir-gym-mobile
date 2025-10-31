import 'package:elixir_gym/data/models/training.dart';
import 'package:elixir_gym/data/models/training_exercise.dart';
import 'package:elixir_gym/data/services/training_exercise_service.dart';
import 'package:elixir_gym/data/services/training_service.dart';
import 'package:flutter/foundation.dart';

class TrainerTrainingProvider extends ChangeNotifier {
  final TrainingService _service = TrainingService();
  final TrainingExerciseService _trainingExerciseService =
      TrainingExerciseService();

  List<Entrenamiento> trainings = [];
  bool isLoading = false;
  String? error;

  List<TrainingExercise> assignedExercises = [];
  bool isExercisesLoading = false;
  String? exercisesError;

  Future<void> loadAssignedExercises(int trainingId) async {
    isExercisesLoading = true;
    exercisesError = null;
    notifyListeners();

    try {
      // Llama al nuevo método que creaste en tu servicio
      assignedExercises = await _trainingExerciseService.fetchAllTraining(
        trainingId,
      );
    } catch (e) {
      exercisesError = 'Error al cargar los ejercicios: $e';
    } finally {
      isExercisesLoading = false;
      notifyListeners();
    }
  }

  void clearAssignedExercises() {
    assignedExercises = [];
  }

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

  Future<void> addExerciseToTraining({
    required int idEntrenamiento,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    required double pesoSugerido,
    required int descansoSegundos,
  }) async {
    try {
      // Llama al servicio para crear la relación en el backend
      await _trainingExerciseService.create(
        idEntrenamiento: idEntrenamiento,
        idEjercicio: idEjercicio,
        series: series,
        repeticiones: repeticiones,
        pesoSugerido: pesoSugerido,
        descansoSegundos: descansoSegundos,
      );
    } catch (e) {
      // Propaga el error para que la UI pueda mostrarlo
      throw Exception('Error al asignar el ejercicio: $e');
    }
  }

  Future<void> updateAssignedExercise({
    required int idEntrenamiento,
    required int idEjercicio,
    required int series,
    required int repeticiones,
    required double pesoSugerido,
    required int descansoSegundos,
  }) async {
    try {
      // 1. Llama al servicio para que actualice los datos en el backend
      await _trainingExerciseService.update(
        idEntrenamiento: idEntrenamiento,
        idEjercicio: idEjercicio,
        series: series,
        repeticiones: repeticiones,
        pesoSugerido: pesoSugerido,
        descansoSegundos: descansoSegundos,
      );

      // 2. Busca el ejercicio en la lista local para actualizarlo
      final index = assignedExercises.indexWhere(
        (ex) =>
            ex.idEntrenamiento == idEntrenamiento &&
            ex.idEjercicio == idEjercicio,
      );

      if (index != -1) {
        // Reemplaza el objeto antiguo con el nuevo con los datos actualizados
        assignedExercises[index] = TrainingExercise(
          idEntrenamiento: idEntrenamiento,
          idEjercicio: idEjercicio,
          // Mantenemos el nombre que ya teníamos cargado
          nombre: assignedExercises[index].nombre,
          series: series,
          repeticiones: repeticiones,
          pesoSugerido: pesoSugerido,
          descansoSegundos: descansoSegundos,
        );
        // Notifica a la UI para que se redibuje con los nuevos datos
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar el ejercicio: $e');
    }
  }

  Future<void> removeExerciseFromTraining(
    int idEntrenamiento,
    int idEjercicio,
  ) async {
    try {
      // 1. Llama al servicio para que lo elimine en el backend
      await _trainingExerciseService.delete(idEntrenamiento, idEjercicio);

      // 2. Elimina el ejercicio de la lista local para actualizar la UI al instante
      assignedExercises.removeWhere(
        (exercise) =>
            exercise.idEntrenamiento == idEntrenamiento &&
            exercise.idEjercicio == idEjercicio,
      );

      // 3. Notifica a la UI que la lista ha cambiado
      notifyListeners();
    } catch (e) {
      // Si algo falla, propaga el error para que la UI pueda mostrarlo
      throw Exception('Error al eliminar el ejercicio del entrenamiento: $e');
    }
  }
}
