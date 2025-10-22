import 'package:elixir_gym/presentation/screens/trainer/class_creation_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/classes_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/clases': (context) => const ClassesScreen(),
    '/crear-clase': (context) => const ClassCreationScreen(),
  };
}
