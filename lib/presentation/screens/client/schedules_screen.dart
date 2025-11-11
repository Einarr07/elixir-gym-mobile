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

Widget _HorarioCard(BuildContext context, Schedule schedule) {
  final inicio = _formatearHora(schedule.horaInicio);
  final fin = _formatearHora(schedule.horaFin);

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClassDetailScreen(horario: schedule)),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF292716),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.clase.nombre} con ${schedule.entrenador.nombre} ${schedule.entrenador.apellido}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$inicio - $fin',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 18,
          ),
        ],
      ),
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
