// lib/presentation/screens/trainer/exercises_screen.dart
import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/exercise.dart';
import 'package:elixir_gym/presentation/providers/trainer/exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exercise_edit_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial
    Future.microtask(() {
      context.read<TrainerExerciseProvider>().loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerExerciseProvider>();
    final groups = provider.gruposMusculares; // Map<int, String>

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ejercicios',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Buscar
              TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: provider.setQuery,
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicios...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Chips de filtro
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      selected: provider.selectedMuscleGroupId == null,
                      onSelected: (_) => provider.selectMuscleGroup(null),
                    ),
                    const SizedBox(width: 8),
                    ...groups.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: e.value,
                          selected: provider.selectedMuscleGroupId == e.key,
                          onSelected: (_) => provider.selectMuscleGroup(e.key),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Lista
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.card,
                        onRefresh: () => context
                            .read<TrainerExerciseProvider>()
                            .loadExercises(),
                        child: provider.exercises.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 80),
                                  Center(
                                    child: Text(
                                      'No hay ejercicios.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                itemCount: provider.exercises.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  final ex = provider.exercises[i];
                                  return _ExerciseCard(
                                    exercise: ex,
                                    onEdit: () async {
                                      final updated =
                                          await showModalBottomSheet<bool>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) =>
                                                ExerciseEditSheet(exercise: ex),
                                          );

                                      if (updated == true && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ejercicio actualizado',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    onDelete: () async {
                                      final ok =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                'Eliminar ejercicio',
                                              ),
                                              content: Text(
                                                '¿Seguro que deseas eliminar "${ex.nombre ?? 'este ejercicio'}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;

                                      if (!ok) return;

                                      try {
                                        final id = ex.idEjercicio;
                                        if (id == null) {
                                          throw Exception('idEjercicio nulo');
                                        }
                                        await context
                                            .read<TrainerExerciseProvider>()
                                            .deleteExercise(id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Ejercicio eliminado',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_exercise',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pushNamed(context, '/crear-ejercicio');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: selected ? Colors.black : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = exercise.nombre ?? '—';
    final descripcion = (exercise.descripcion ?? '').trim();
    final grupoNombre =
        exercise.grupoMuscular?.nombre ?? exercise.nombre ?? '—';

    // Si tu modelo trae equipos, puedes mostrar conteo
    final equiposCount = _countEquipos(exercise);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna principal (sin imagen)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                // Descripción (si existe)
                if (descripcion.isNotEmpty)
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 8),
                // Pills: grupo + equipos
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Pill(text: grupoNombre),
                    if (equiposCount != null)
                      _Pill(text: 'Equipos: $equiposCount'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Acciones
          Column(
            children: [
              _ActionIcon(
                icon: Icons.edit,
                bg: AppColors.primary,
                fg: Colors.black,
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _ActionIcon(
                icon: Icons.delete,
                bg: const Color(0xFFEF5350),
                fg: Colors.white,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? _countEquipos(Exercise e) {
    // Ajusta según tu modelo real:
    // - si tienes e.equipos como List<Equipo>, devuelve e.equipos.length
    // - si no llega del back, devuelve null para ocultar el pill
    try {
      final dynamic equipos = (e as dynamic).equipos;
      if (equipos is List) return equipos.length;
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF333028),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}
