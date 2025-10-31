import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/training.dart';
import 'package:elixir_gym/data/models/training_exercise.dart'; // 👈 1. IMPORTA TU MODELO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trainer/training_provider.dart';

// 2. CONVIERTE LA CLASE A STATEFULWIDGET
class TrainingDetailScreen extends StatefulWidget {
  final Entrenamiento entrenamiento;

  const TrainingDetailScreen({super.key, required this.entrenamiento});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 3. CARGA LOS DATOS CUANDO LA PANTALLA SE INICIA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainerTrainingProvider>(
        context,
        listen: false,
      ).loadAssignedExercises(widget.entrenamiento.idEntrenamiento!);
    });
  }

  @override
  void dispose() {
    // 4. LIMPIA LOS DATOS AL SALIR DE LA PANTALLA
    // Esto evita mostrar datos viejos si se abre otro entrenamiento después.
    Provider.of<TrainerTrainingProvider>(
      context,
      listen: false,
    ).clearAssignedExercises();
    super.dispose();
  }

  Color _getNivelColor(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'PRINCIPIANTE':
        return Colors.green;
      case 'INTERMEDIO':
        return Colors.orange;
      case 'AVANZADO':
        return Colors.redAccent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accede a las propiedades del widget con `widget.`
    final nivelColor = _getNivelColor(widget.entrenamiento.nivel);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.entrenamiento.nombre,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    'Confirmar eliminación',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    '¿Estás seguro de eliminar este entrenamiento?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  final provider = Provider.of<TrainerTrainingProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteTraining(
                    widget.entrenamiento.idEntrenamiento!,
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // cerrar pantalla detalle
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrenamiento eliminado correctamente'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst("Exception: ", ""),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO Y DESCRIPCIÓN ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: nivelColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.entrenamiento.nivel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.schedule, color: AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.entrenamiento.semanasDeDuracion} semanas',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.entrenamiento.descripcion,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // --- SUBTÍTULO Y BOTÓN AGREGAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ejercicios del Programa',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/asignar-ejercicio',
                      arguments: widget.entrenamiento.idEntrenamiento,
                    );
                    if (result == true && context.mounted) {
                      // 5. RECARGA LA LISTA DESPUÉS DE AÑADIR UN EJERCICIO
                      Provider.of<TrainerTrainingProvider>(
                        context,
                        listen: false,
                      ).loadAssignedExercises(
                        widget.entrenamiento.idEntrenamiento!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ejercicio asignado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: const Text(
                    'Agregar',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 6. REEMPLAZA LA LISTA QUEMADA CON UN CONSUMER DINÁMICO
            Expanded(
              child: Consumer<TrainerTrainingProvider>(
                builder: (context, provider, child) {
                  // Muestra un indicador de carga mientras los datos llegan
                  if (provider.isExercisesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Muestra un error si algo falló
                  if (provider.exercisesError != null) {
                    return Center(
                      child: Text(
                        provider.exercisesError!,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Muestra un mensaje si no hay ejercicios
                  if (provider.assignedExercises.isEmpty) {
                    return const Center(
                      child: Text('Aún no hay ejercicios asignados.'),
                    );
                  }

                  // Muestra la lista de ejercicios reales
                  return ListView.builder(
                    itemCount: provider.assignedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = provider.assignedExercises[index];
                      return _buildExerciseCard(context, exercise, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. WIDGET REUTILIZABLE PARA CONSTRUIR LA TARJETA DEL EJERCICIO
  Widget _buildExerciseCard(
    BuildContext context,
    TrainingExercise exercise,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withOpacity(0.9),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        exercise.nombre ?? 'Ejercicio sin nombre',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // --- BOTÓN DE EDICIÓN ---
              IconButton(
                onPressed: () {
                  // Llama al método para mostrar el diálogo de edición
                  _showEditExerciseDialog(context, exercise);
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primary, // Un color que sugiera edición
                  size: 20,
                ),
              ),
              // --- BOTÓN DE ELIMINACIÓN ---
              IconButton(
                onPressed: () async {
                  final bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.card,
                        title: const Text(
                          'Confirmar eliminación',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: Text(
                          '¿Seguro que quieres quitar "${exercise.nombre ?? 'este ejercicio'}" del entrenamiento?',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true && context.mounted) {
                    try {
                      final provider = Provider.of<TrainerTrainingProvider>(
                        context,
                        listen: false,
                      );
                      await provider.removeExerciseFromTraining(
                        widget.entrenamiento.idEntrenamiento!,
                        exercise.idEjercicio,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ejercicio quitado del entrenamiento.'),
                          backgroundColor:
                              Colors.green, // Cambiado a verde para éxito
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al quitar ejercicio: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoBox(label: 'Series', value: exercise.series.toString()),
              _InfoBox(label: 'Reps', value: exercise.repeticiones.toString()),
              _InfoBox(
                label: 'Descanso',
                value: '${exercise.descansoSegundos}s',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Peso sugerido: ${exercise.pesoSugerido} kg',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // 2. NUEVO MÉTODO PARA MOSTRAR EL DIÁLOGO DE EDICIÓN
  void _showEditExerciseDialog(
    BuildContext context,
    TrainingExercise exercise,
  ) {
    // Controladores pre-llenados con los datos actuales
    final seriesController = TextEditingController(
      text: exercise.series.toString(),
    );
    final repsController = TextEditingController(
      text: exercise.repeticiones.toString(),
    );
    final weightController = TextEditingController(
      text: exercise.pesoSugerido.toString(),
    );
    final restController = TextEditingController(
      text: exercise.descansoSegundos.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Editar "${exercise.nombre ?? 'Ejercicio'}"',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: seriesController,
                  decoration: const InputDecoration(labelText: 'Series'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso Sugerido (kg)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: restController,
                  decoration: const InputDecoration(
                    labelText: 'Descanso (segundos)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Parsear los nuevos valores
                final series =
                    int.tryParse(seriesController.text) ?? exercise.series;
                final repeticiones =
                    int.tryParse(repsController.text) ?? exercise.repeticiones;
                final pesoSugerido =
                    double.tryParse(weightController.text) ??
                    exercise.pesoSugerido;
                final descansoSegundos =
                    int.tryParse(restController.text) ??
                    exercise.descansoSegundos;

                try {
                  final provider = Provider.of<TrainerTrainingProvider>(
                    context,
                    listen: false,
                  );

                  // Llamar al método de actualización
                  await provider.updateAssignedExercise(
                    idEntrenamiento: widget.entrenamiento.idEntrenamiento!,
                    idEjercicio: exercise.idEjercicio,
                    series: series,
                    repeticiones: repeticiones,
                    pesoSugerido: pesoSugerido,
                    descansoSegundos: descansoSegundos,
                  );

                  if (mounted) {
                    Navigator.of(dialogContext).pop(); // Cierra el diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ejercicio actualizado correctamente.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // NO usamos Expanded aquí.
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          // 1. Añadimos padding horizontal para que no quede muy apretado.
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
