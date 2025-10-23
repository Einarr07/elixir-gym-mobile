import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/training.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trainer/training_provider.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TrainerTrainingProvider>(
        context,
        listen: false,
      ).loadTrainings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainerTrainingProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Entrenamientos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (provider.trainings.isEmpty) {
              return const Center(
                child: Text(
                  'No hay entrenamientos disponibles.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.trainings.length,
              itemBuilder: (context, index) {
                final training = provider.trainings[index];
                return _TrainingCard(training: training);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.card,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const _AddTrainingSheet(),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final Entrenamiento training;

  const _TrainingCard({required this.training});

  Color _getNivelColor(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'PRINCIPIANTE':
        return Colors.green;
      case 'INTERMEDIO':
        return Colors.orange;
      case 'AVANZADO':
        return Colors.redAccent;
      default:
        return AppColors.primary; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivelColor = _getNivelColor(training.nivel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: nivelColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: nivelColor.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: nivelColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                training.nivel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            training.nombre,
            style: TextStyle(
              color: nivelColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            training.descripcion,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: nivelColor),
              const SizedBox(width: 4),
              Text(
                '${training.semanasDeDuracion} semanas',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: nivelColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/detalle-entrenamiento',
                  arguments: training,
                );
              },
              child: const Text(
                'Ver detalles',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTrainingSheet extends StatefulWidget {
  const _AddTrainingSheet();

  @override
  State<_AddTrainingSheet> createState() => _AddTrainingSheetState();
}

class _AddTrainingSheetState extends State<_AddTrainingSheet> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _semanasController = TextEditingController();

  String _nivelSeleccionado = 'PRINCIPIANTE';

  final List<String> _niveles = ['PRINCIPIANTE', 'INTERMEDIO', 'AVANZADO'];
  final List<Color> _colores = [Colors.green, Colors.orange, Colors.redAccent];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo entrenamiento',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _CustomField(
              controller: _nombreController,
              hint: 'Nombre del entrenamiento',
            ),
            const SizedBox(height: 8),
            _CustomField(
              controller: _descripcionController,
              hint: 'Descripción',
            ),
            const SizedBox(height: 16),
            _buildNivelSelector(),
            const SizedBox(height: 16),
            _CustomField(
              controller: _semanasController,
              hint: 'Semanas de duración',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final nombre = _nombreController.text.trim();
                  final descripcion = _descripcionController.text.trim();
                  final semanas =
                      int.tryParse(_semanasController.text.trim()) ?? 0;
                  final nivel = _nivelSeleccionado
                      .toLowerCase(); // para el backend

                  if (nombre.isEmpty || descripcion.isEmpty || semanas <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor completa todos los campos correctamente',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    final provider = Provider.of<TrainerTrainingProvider>(
                      context,
                      listen: false,
                    );

                    final nuevo = await provider.createTraining(
                      nombre: nombre,
                      descripcion: descripcion,
                      nivel: nivel,
                      semanasDeDuracion: semanas,
                    );
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrenamiento creado con éxito'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear entrenamiento: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },

                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Selector visual de nivel (PRINCIPIANTE, INTERMEDIO, AVANZADO)
  Widget _buildNivelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nivel de dificultad',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_niveles.length, (i) {
            final nivel = _niveles[i];
            final color = _colores[i];
            final isSelected = _nivelSeleccionado == nivel;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _nivelSeleccionado = nivel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == _niveles.length - 1 ? 0 : 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.9)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      nivel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.black
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _CustomField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
