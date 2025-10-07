import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:flutter/material.dart';

class ClassDetailScreen extends StatelessWidget {
  final Clase clase;

  const ClassDetailScreen({super.key, required this.clase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Detalle de la Clase',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clase.nombre,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              clase.descripcion,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Text('Dificultad: ${clase.dificultad ?? "No especificada"}'),

            _InfoItem(
              icon: Icons.timer,
              label: 'Duración',
              value: '${clase.duracion} minutos',
            ),
            _InfoItem(
              icon: Icons.people,
              label: 'Capacidad Máxima',
              value: '${clase.capacidadMax} personas',
            ),
            const SizedBox(height: 20),
            Text(
              'Sumérgete en una experiencia de entrenamiento completa que desafiará tus límites y te ayudará a alcanzar tus objetivos. Ideal para quienes buscan un desafío dinámico y motivador.',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Reservar Cupo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
