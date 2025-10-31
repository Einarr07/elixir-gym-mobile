// lib/presentation/screens/trainer/exercise_edit_sheet.dart
import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/equipment.dart';
import 'package:elixir_gym/data/models/exercise.dart';
import 'package:elixir_gym/data/services/equipment_service.dart';
import 'package:elixir_gym/presentation/providers/trainer/exercise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseEditSheet extends StatefulWidget {
  const ExerciseEditSheet({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<ExerciseEditSheet> createState() => _ExerciseEditSheetState();
}

class _ExerciseEditSheetState extends State<ExerciseEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;

  int? _grupoSeleccionado;
  bool _saving = false;

  // ---- Equipos ----
  final EquipmentService _equipmentService = EquipmentService();
  List<Equipment> _equiposAll = const [];
  final Set<int> _selectedEquipoIds = <int>{};
  bool _loadingEquipos = false;

  @override
  void initState() {
    super.initState();

    _nombreCtrl = TextEditingController(text: widget.exercise.nombre ?? '');
    _descripcionCtrl = TextEditingController(
      text: widget.exercise.descripcion ?? '',
    );

    _grupoSeleccionado = widget.exercise.grupoMuscular?.idGrupoMuscular;

    final iniciales = _initialEquipos(widget.exercise);
    _selectedEquipoIds.addAll(
      iniciales.map((e) => e.idEquipo).whereType<int>(),
    );
    _equiposAll = List<Equipment>.from(iniciales);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_equiposAll.isEmpty && _selectedEquipoIds.isNotEmpty) {
        _loadEquipos();
      }
    });
  }

  List<Equipment> _initialEquipos(Exercise e) {
    try {
      final dyn = e as dynamic;
      final v = dyn.equipos;
      if (v is List<Equipment>) return v;
      if (v is List) {
        return v
            .map(
              (x) => x is Equipment
                  ? x
                  : Equipment.fromJson(x as Map<String, dynamic>),
            )
            .toList();
      }
      return e.equipos ?? [];
    } catch (_) {
      return const [];
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_grupoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un grupo muscular')),
      );
      return;
    }

    final nombresEquipos = _selectedEquipoIds
        .map((id) {
          return _equiposAll
              .firstWhere(
                (e) => e.idEquipo == id,
                orElse: () => Equipment(idEquipo: id, nombre: ''),
              )
              .nombre;
        })
        .where((nombre) => nombre != null && nombre.isNotEmpty)
        .toList();

    final equipoNecesarioStr = nombresEquipos.join(', ');

    if (equipoNecesarioStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un equipo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<TrainerExerciseProvider>().updateExercise(
        idEjercicio: widget.exercise.idEjercicio!,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),

        equipoNecesario: equipoNecesarioStr,
        idGrupoMuscular: _grupoSeleccionado!,
        idsEquipos: _selectedEquipoIds.toList(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadEquipos() async {
    if (_loadingEquipos) return;
    setState(() => _loadingEquipos = true);
    try {
      final items = await _equipmentService.fetchAll();
      _equiposAll = items;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los equipos: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingEquipos = false);
    }
  }

  Future<void> _openEquiposSelector() async {
    await _loadEquipos();
    if (!mounted) return;

    final Set<int> temp = Set<int>.from(_selectedEquipoIds);
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _EquiposSelectorSheet(
          all: _equiposAll,
          initialSelected: temp,
          onChanged: (newSet) => temp
            ..clear()
            ..addAll(newSet),
        );
      },
    );

    // El selector muta el set por referencia; si prefieres devolver explícito,
    // ajusta el builder para retornar el set y úsalo con Navigator.pop(context, set).
    setState(() {
      _selectedEquipoIds
        ..clear()
        ..addAll(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grupos = context.watch<TrainerExerciseProvider>().gruposMusculares;

    // Altura casi completa con borde redondeado arriba
    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: media.size.height * 0.86,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Handle
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4436),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    const Text(
                      'Editar ejercicio',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nombre
                    TextFormField(
                      controller: _nombreCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _decor('Nombre del ejercicio'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa un nombre'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    TextFormField(
                      controller: _descripcionCtrl,
                      minLines: 2,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _decor('Descripción'),
                    ),
                    const SizedBox(height: 12),

                    // ------ Equipos (selector) ------
                    Row(
                      children: [
                        const Text(
                          'Equipos',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openEquiposSelector,
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          label: const Text(
                            'Seleccionar',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (_selectedEquipoIds.isEmpty)
                      const Text(
                        'Sin equipos seleccionados',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedEquipoIds
                            .map(
                              (id) => _EquipoChip(
                                id: id,
                                name:
                                    _equiposAll
                                        .firstWhere(
                                          (e) => e.idEquipo == id,
                                          orElse: () => Equipment(
                                            idEquipo: id,
                                            nombre: 'ID $id',
                                            tipo: '',
                                            estado: '',
                                          ),
                                        )
                                        .nombre ??
                                    'ID $id',
                                onRemove: () => setState(() {
                                  _selectedEquipoIds.remove(id);
                                }),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: 16),

                    const Text(
                      'Grupo muscular',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in grupos.entries)
                          ChoiceChip(
                            label: Text(entry.value),
                            selected: _grupoSeleccionado == entry.key,
                            onSelected: (_) =>
                                setState(() => _grupoSeleccionado = entry.key),
                            labelStyle: TextStyle(
                              color: _grupoSeleccionado == entry.key
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFF333028),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saving ? null : _onSave,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Hoja de selección de equipos (con búsqueda y checkboxes)
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
  String _q = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<int>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final filtered = widget.all.where((e) {
      if (_q.trim().isEmpty) return true;
      final n = (e.nombre ?? '').toLowerCase();
      return n.contains(_q.toLowerCase());
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFF3A352A), height: 1),
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final id = item.idEquipo!;
                  final selected = _tempSelected.contains(id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) {
                      setState(() {
                        if (selected) {
                          _tempSelected.remove(id);
                        } else {
                          _tempSelected.add(id);
                        }
                      });
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

class _EquipoChip extends StatelessWidget {
  const _EquipoChip({
    required this.id,
    required this.name,
    required this.onRemove,
  });

  final int id;
  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF333028),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A4436)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
