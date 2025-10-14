import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/presentation/screens/client/profile_screen.dart';
import 'package:elixir_gym/presentation/screens/client/reservation_screen.dart';
import 'package:elixir_gym/presentation/screens/client/schedules_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIdex = 0;

  // List of screens
  final List<Widget> _screens = const [
    SchedulesScreen(),
    ReservasScreen(),
    ProfileScreen(usuarioId: 4),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIdex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIdex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIdex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
