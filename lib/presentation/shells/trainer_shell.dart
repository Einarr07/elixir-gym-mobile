// lib/presentation/shells/trainer_shell.dart
import 'package:elixir_gym/presentation/screens/client/profile_screen.dart';
import 'package:elixir_gym/presentation/screens/trainer/classes_screen.dart';
import 'package:flutter/material.dart';

import '../screens/trainer/training_screen.dart';

class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  int idx = 0;
  final pages = const [ClassesScreen(), TrainingScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_sharp),
            label: 'Clases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Entrenamientos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
