import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/trainer/schedule_provider.dart';

// 1. Renombramos el widget para que sea más claro
class ScheduleEditScreen extends StatefulWidget {
  const ScheduleEditScreen({super.key});

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Datos del formulario
  Clase? _selectedClase;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Estado de carga
  bool _isLoadingData = true;
  String? _loadingError;
  bool _isUpdating = false;

  // Datos del horario a editar
  int? _horarioId;
  Schedule? _existingSchedule;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtenemos el ID del horario de los argumentos de la ruta
    // Solo se ejecuta la primera vez
    if (_horarioId == null) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg != null && arg is int) {
        _horarioId = arg;
        _loadScheduleAndClasses();
      } else {
        // Error: no se recibió un ID válido
        setState(() {
          _isLoadingData = false;
          _loadingError = 'Error: No se recibió un ID de horario válido.';
        });
      }
    }
  }

  Future<void> _loadScheduleAndClasses() async {
    setState(() {
      _isLoadingData = true;
      _loadingError = null;
    });
    final scheduleProvider = Provider.of<TrainerScheduleProvider>(
      context,
      listen: false,
    );

    try {
      // 1. Cargamos ambas listas en paralelo
      await Future.wait([
        scheduleProvider.loadHorarios(), // Carga la lista de horarios
        scheduleProvider.loadClases(), // Carga la lista de clases
      ]);

      if (scheduleProvider.error != null) {
        throw Exception(scheduleProvider.error);
      }

      // 2. Buscamos el horario específico a editar
      // Usamos 'sortedHorarios' que tiene la data combinada
      _existingSchedule = scheduleProvider.sortedHorarios.firstWhere(
        (h) => h.idHorario == _horarioId,
        orElse: () =>
            throw Exception('No se encontró el horario con ID $_horarioId'),
      );

      // 3. Buscamos la clase seleccionada en la lista de clases
      _selectedClase = scheduleProvider.clases.firstWhere(
        (c) => c.idClase == _existingSchedule!.clase.idClase,
        orElse: () => throw Exception(
          'La clase para este horario no se encontró o no está disponible.',
        ),
      );

      // 4. Pre-populamos el formulario
      _selectedDate = _existingSchedule!.fecha;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);

      // 5. Asumimos que horaInicio/horaFin en el modelo Schedule son String "HH:mm"
      // (basado en cómo el 'ScheduleService' crea las entradas)
      final timeFormat = DateFormat('HH:mm');

      final startTimeParsed = timeFormat.parse(_existingSchedule!.horaInicio);
      _startTime = TimeOfDay.fromDateTime(startTimeParsed);
      _startTimeController.text = _startTime!.format(context);

      final endTimeParsed = timeFormat.parse(_existingSchedule!.horaFin);
      _endTime = TimeOfDay.fromDateTime(endTimeParsed);
      _endTimeController.text = _endTime!.format(context);
    } catch (e) {
      setState(() {
        _loadingError = "Error al cargar datos: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // --- Selectores de Fecha y Hora (Sin cambios) ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      // Opcional: permitir editar fechas pasadas?
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.card,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _startTime : _endTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.card,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  // --- Lógica de Envío (Actualizada) ---

  Future<void> _submitUpdateForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación de hora
    if (_startTime == null || _endTime == null) return;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de fin debe ser posterior a la hora de inicio.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<TrainerScheduleProvider>(
        context,
        listen: false,
      );

      final instructorId = authProvider.usuario?.idUsuario;
      if (instructorId == null) {
        throw Exception('No se pudo identificar al instructor.');
      }

      // Combinar fecha y horas
      final fecha = _selectedDate!;
      final horaInicio = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final horaFin = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Llamamos al provider para actualizar el horario
      await scheduleProvider.actualizarHorario(
        idHorario: _horarioId!,
        // <-- ID del horario a actualizar
        claseId: _selectedClase!.idClase!,
        instructorId: instructorId,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );

      if (scheduleProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario actualizado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresamos a la pantalla anterior con 'true'
        Navigator.pop(context, true);
      } else {
        throw Exception(scheduleProvider.error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el horario: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // --- Lógica de Eliminación ---

  Future<void> _confirmDelete() async {
    // 1. Mostrar diálogo de confirmación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Eliminar Horario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este horario? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
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

    if (confirm != true) return;

    setState(() {
      _isUpdating = true; // Reusamos la variable de carga para bloquear la UI
    });

    try {
      final scheduleProvider = Provider.of<TrainerScheduleProvider>(
        context,
        listen: false,
      );

      // 2. Llamar al método del provider (asegúrate de tener este método en tu provider)
      await scheduleProvider.eliminarHorario(_horarioId!);

      if (scheduleProvider.error == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario eliminado con éxito.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        // Regresamos indicando que hubo cambios (true)
        Navigator.pop(context, true);
      } else {
        throw Exception(scheduleProvider.error);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // --- Construcción de UI ---

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final instructorName = authProvider.usuario?.nombre ?? 'Entrenador';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Editar Horario', // <- Título cambiado
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(instructorName),
    );
  }

  Widget _buildBody(String instructorName) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _loadingError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.0),
          ),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel('Clase'),
                _buildClaseDropdown(),
                const SizedBox(height: 16),
                _buildLabel('Fecha'),
                _buildDatePicker(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Hora Inicio'),
                          _buildTimePicker(isStartTime: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Hora Fin'),
                          _buildTimePicker(isStartTime: false),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Instructor asignado'),
                _buildReadOnlyField('$instructorName (Usuario actual)'),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildDeleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares (Casi sin cambios) ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildClaseDropdown() {
    // Nota: El 'Consumer' aquí se convierte en 'Selector' para optimizar
    // o se puede quedar como Consumer si 'loadClases' no notifica.
    // Lo mantenemos simple por ahora.
    return Consumer<TrainerScheduleProvider>(
      builder: (context, provider, child) {
        // No usamos _isClassesLoading, usamos _isLoadingData general
        if (provider.clases.isEmpty && _loadingError == null) {
          return const Center(child: Text('Cargando clases...'));
        }

        return DropdownButtonFormField<Clase>(
          value: _selectedClase,
          // <- Valor pre-populado
          hint: const Text(
            'Selecciona una clase',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          dropdownColor: AppColors.card,
          decoration: _inputDecoration(hintText: ''),
          style: const TextStyle(color: AppColors.textPrimary),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
          items: provider.clases.map((Clase clase) {
            return DropdownMenuItem<Clase>(
              value: clase,
              child: Text(clase.nombre),
            );
          }).toList(),
          onChanged: (Clase? newValue) {
            setState(() {
              _selectedClase = newValue;
            });
          },
          validator: (value) => value == null ? 'Selecciona una clase' : null,
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      // <- Controlador pre-populado
      readOnly: true,
      decoration: _inputDecoration(
        hintText: 'dd/mm/aaaa',
        icon: Icons.calendar_today,
        onIconPressed: _selectDate,
      ),
      onTap: _selectDate,
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una fecha' : null,
    );
  }

  Widget _buildTimePicker({required bool isStartTime}) {
    return TextFormField(
      controller: isStartTime ? _startTimeController : _endTimeController,
      // <- Controlador pre-populado
      readOnly: true,
      decoration: _inputDecoration(
        hintText: '--:--',
        icon: Icons.access_time,
        onIconPressed: () => _selectTime(isStartTime),
      ),
      onTap: () => _selectTime(isStartTime),
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una hora' : null,
    );
  }

  Widget _buildReadOnlyField(String text) {
    return TextFormField(
      // Usamos 'key' para asegurar que se reconstruya si 'text' cambia
      key: ValueKey(text),
      initialValue: text,
      readOnly: true,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: _inputDecoration(hintText: '').copyWith(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 0,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _submitUpdateForm,
        // <- Llama a _submitUpdateForm
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child:
            _isUpdating // <- Usa _isUpdating
            ? const SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Actualizar Horario', // <- Texto cambiado
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isUpdating ? null : _confirmDelete,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Eliminar Horario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  // --- Decoraciones reutilizables (Sin cambios) ---

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      // Color de fondo de los inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
      suffixIcon: icon != null
          ? IconButton(
              icon: Icon(icon, color: AppColors.textSecondary),
              onPressed: onIconPressed,
            )
          : null,
    );
  }
}
