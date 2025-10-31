import 'package:elixir_gym/data/models/training.dart';
import 'package:elixir_gym/presentation/screens/trainer/class_creation_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/class_edit_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/classes_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/exercise_creation_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/training_details_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/clases': (context) => const ClassesScreen(),
    '/crear-clase': (context) => const ClassCreationScreen(),
    '/editar-clase': (context) {
      final idClase = ModalRoute.of(context)!.settings.arguments as int;
      return ClassEditScreen(idClase: idClase);
    },
    // Entrenamiento
    '/detalle-entrenamiento': (context) {
      final entrenamiento =
          ModalRoute.of(context)!.settings.arguments as Entrenamiento;
      return TrainingDetailScreen(entrenamiento: entrenamiento);
    },
    '/crear-ejercicio': (context) => const ExerciseCreationScreen(),
  };
}
