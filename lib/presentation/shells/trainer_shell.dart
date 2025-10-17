// lib/presentation/shells/trainer_shell.dart
import 'package:flutter/material.dart';

class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  int idx = 0;
  final pages = const [
    Center(child: Text('Agenda Entrenador')),
    Center(child: Text('Alumnos')),
    Center(child: Text('Perfil Entrenador')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Alumnos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
