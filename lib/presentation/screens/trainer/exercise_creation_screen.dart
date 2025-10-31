import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/equipment.dart';
import 'package:elixir_gym/data/models/exercise.dart';
import 'package:elixir_gym/presentation/providers/trainer/exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseCreationScreen extends StatefulWidget {
  const ExerciseCreationScreen({super.key});

  @override
  State<ExerciseCreationScreen> createState() => _ExerciseCreationScreenState();
}

class _ExerciseCreationScreenState extends State<ExerciseCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedMuscleGroupId;

  // Usamos un Set de IDs para manejar los equipos seleccionados, igual que en la pantalla de edición.
  final Set<int> _selectedEquipoIds = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Usamos Future.microtask para asegurar que el context está disponible.
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    // Se asegura de que el widget todavía esté en el árbol antes de interactuar con el provider.
    if (!mounted) return;
    try {
      final provider = context.read<TrainerExerciseProvider>();
      // Llama al método del provider que carga tanto grupos musculares como equipos.
      await provider.loadFormData();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del formulario: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMuscleGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un grupo muscular'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final allEquipments = context
          .read<TrainerExerciseProvider>()
          .equipmentsForForm;

      final nombresEquipos = _selectedEquipoIds
          .map(
            (id) => allEquipments
                .firstWhere(
                  (e) => e.idEquipo == id,
                  orElse: () => Equipment(idEquipo: id, nombre: ''),
                )
                .nombre,
          )
          .where((nombre) => nombre.isNotEmpty)
          .toList();

      final equipoNecesarioStr = nombresEquipos.join(', ');

      if (equipoNecesarioStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar al menos un equipo')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final selectedEquipmentsObjects = allEquipments
          .where((equipment) => _selectedEquipoIds.contains(equipment.idEquipo))
          .toList();

      final newExercise = Exercise(
        nombre: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        idGrupoMuscular: _selectedMuscleGroupId,
        // Pasamos la lista de IDs para el campo `equipos`.
        equiposIds: _selectedEquipoIds.toList(),
        // Pasamos el string de nombres para el campo `equipo_necesario`.
        equipoNecesario: equipoNecesarioStr,
        equipos: selectedEquipmentsObjects,
      );

      await context.read<TrainerExerciseProvider>().createExercise(newExercise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio creado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Devuelve true para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el ejercicio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Nuevo método para abrir el selector modal de equipos.
  Future<void> _openEquipmentSelector() async {
    if (!mounted) return;
    final allEquipments = context
        .read<TrainerExerciseProvider>()
        .equipmentsForForm;

    // Usamos un Set temporal que se modifica dentro del modal.
    final Set<int> tempSelected = Set<int>.from(_selectedEquipoIds);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _EquiposSelectorSheet(
          all: allEquipments,
          initialSelected: tempSelected,
          // El modal actualiza el Set `tempSelected` directamente.
          onChanged: (newSet) => tempSelected
            ..clear()
            ..addAll(newSet),
        );
      },
    );

    // Al cerrar el modal, actualizamos el estado de la pantalla principal.
    setState(() {
      _selectedEquipoIds
        ..clear()
        ..addAll(tempSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerExerciseProvider>();
    final allMuscleGroups = provider.muscleGroupsForForm;
    final allEquipments = provider.equipmentsForForm;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Crear Ejercicio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Nombre del ejercicio'),
                      validator: (value) => (value ?? '').isEmpty
                          ? 'El nombre es requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Descripción (opcional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Equipos'),
                    const SizedBox(height: 8),
                    // Este GestureDetector ahora abre el nuevo selector modal.
                    GestureDetector(
                      onTap: _openEquipmentSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seleccionar equipos...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Icon(
                              Icons.tune,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // El Wrap ahora construye los chips a partir de la lista de IDs.
                    if (_selectedEquipoIds.isEmpty)
                      const Text(
                        'Ningún equipo seleccionado',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedEquipoIds.map((id) {
                          // Buscamos el objeto completo para obtener el nombre.
                          final equipment = allEquipments.firstWhere(
                            (e) => e.idEquipo == id,
                            orElse: () =>
                                Equipment(idEquipo: id, nombre: 'ID $id'),
                          );
                          return Chip(
                            label: Text(equipment.nombre ?? 'N/A'),
                            backgroundColor: AppColors.card,
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedEquipoIds.remove(id);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Grupo muscular'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: allMuscleGroups.map((group) {
                        return ChoiceChip(
                          label: Text(group.nombre ?? 'N/A'),
                          selected:
                              _selectedMuscleGroupId == group.idGrupoMuscular,
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                () => _selectedMuscleGroupId =
                                    group.idGrupoMuscular,
                              );
                            }
                          },
                          labelStyle: TextStyle(
                            color:
                                _selectedMuscleGroupId == group.idGrupoMuscular
                                ? Colors.black
                                : AppColors.textPrimary,
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Guardar Ejercicio',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// =========================================================================
// WIDGET INTERNO PARA SELECCIONAR EQUIPOS (COPIADO DE LA PANTALLA DE EDICIÓN)
// =========================================================================
class _EquiposSelectorSheet extends StatefulWidget {
  const _EquiposSelectorSheet({
    required this.all,
    required this.initialSelected,
    required this.onChanged,
  });

  final List<Equipment> all;
  final Set<int> initialSelected;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_EquiposSelectorSheet> createState() => _EquiposSelectorSheetState();
}

class _EquiposSelectorSheetState extends State<_EquiposSelectorSheet> {
  late Set<int> _tempSelected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<int>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // Filtra la lista de equipos según la búsqueda.
    final filtered = widget.all.where((e) {
      if (_query.trim().isEmpty) return true;
      final name = (e.nombre ?? '').toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();

    return Container(
      height: media.size.height * 0.86,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Handle para arrastrar
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4436),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seleccionar equipos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar equipo...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
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
            ),
            const SizedBox(height: 8),
            // Lista de equipos seleccionables
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFF3A352A), height: 1),
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  final id = item.idEquipo!;
                  final isSelected = _tempSelected.contains(id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) {
                      setState(() {
                        if (isSelected) {
                          _tempSelected.remove(id);
                        } else {
                          _tempSelected.add(id);
                        }
                      });
                      // Notifica a la pantalla principal del cambio.
                      widget.onChanged(_tempSelected);
                    },
                    title: Text(
                      item.nombre ?? 'Equipo $id',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
            // Botón para confirmar y cerrar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Listo',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
