import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../screens/client/profile_screen.dart';
import '../screens/client/reservation_screen.dart';
import '../screens/client/schedules_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int index = 0;

  final pages = const [SchedulesScreen(), ReservationScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
