// lib/presentation/shells/trainer_shell.dart
import 'package:elixir_gym/core/theme/app_colors.dart';
// Si tu perfil del entrenador es otro, cambia esta import:
import 'package:elixir_gym/presentation/screens/client/profile_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/classes_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/exercises_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/training_screen.dart';
import 'package:flutter/material.dart';

class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  int idx = 0;

  // Mantén const si tus pantallas tienen constructor const.
  late final List<Widget> pages = const [
    ClassesScreen(),
    TrainingScreen(),
    ExercisesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // IndexedStack preserva el estado de cada tab
      body: IndexedStack(index: idx, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_sharp),
            label: 'Clases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Entrenamientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Ejercicios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
