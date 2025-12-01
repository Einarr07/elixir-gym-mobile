import 'package:elixir_gym/data/models/schedule.dart';
import 'package:elixir_gym/data/services/schedule_service.dart';
import 'package:elixir_gym/presentation/providers/client/schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import 'class_detail_screen.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final horarioService = ScheduleService();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<HorariosProvider>(context, listen: false).fetchHorarios(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HorariosProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Horarios',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(context, provider),
    );
  }
}

Widget _buildBody(BuildContext context, HorariosProvider provider) {
  if (provider.isLoading) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
  if (provider.errorMessage != null) {
    return Center(child: Text(provider.errorMessage!));
  }

  final horarios = provider.horarios;
  if (horarios.isEmpty) {
    return const Center(
      child: Text(
        "No hay horarios disponibles",
        style: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  final groupedByDate = <String, List<Schedule>>{};
  for (var h in horarios) {
    final date = DateFormat('yyyy-MM-dd').format(h.fecha);
    groupedByDate.putIfAbsent(date, () => []).add(h);
  }

  // Fecha de la más nueva a la más antigua
  final sortedEntries = groupedByDate.entries.toList()
    ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

  return ListView(
    padding: const EdgeInsets.all(16),
    children: groupedByDate.entries.map((entry) {
      final fecha = DateFormat(
        'EEEE d MMMM',
        'es_ES',
      ).format(DateTime.parse(entry.key));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fecha[0].toUpperCase() + fecha.substring(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.value.map((h) => _HorarioCard(context, h)).toList(),
          const SizedBox(height: 16),
        ],
      );
    }).toList(),
  );
}

// Estilo
Color _getDificultadColor(String? dificultad) {
  if (dificultad == null) return AppColors.primary;

  switch (dificultad.toUpperCase()) {
    case 'PRINCIPIANTE':
    case 'BÁSICO':
      return Colors.green;
    case 'INTERMEDIO':
      return Colors.orange;
    case 'AVANZADO':
      return Colors.redAccent;
    default:
      return AppColors.primary;
  }
}

Widget _HorarioCard(BuildContext context, Schedule schedule) {
  final inicio = _formatearHora(schedule.horaInicio);
  final fin = _formatearHora(schedule.horaFin);
  final clase = schedule.clase;
  final color = _getDificultadColor(clase.dificultad);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.9),
        radius: 22,
        child: const Icon(Icons.fitness_center, color: Colors.black),
      ),
      title: Text(
        '${clase.nombre} '
        'con ${schedule.entrenador.nombre} ${schedule.entrenador.apellido}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            '$inicio - $fin',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Duración: ${clase.duracion} min'
            '${clase.dificultad != null ? ' • ${clase.dificultad}' : ''}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 18,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDetailScreen(horario: schedule),
          ),
        );
      },
    ),
  );
}

String _formatearHora(String hora) {
  try {
    final parsed = DateFormat('HH:mm:ss').parse(hora);
    return DateFormat('hh:mm a').format(parsed);
  } catch (_) {
    final parsed = DateFormat('HH:mm').parse(hora);
    return DateFormat('hh:mm a').format(parsed);
  }
}
