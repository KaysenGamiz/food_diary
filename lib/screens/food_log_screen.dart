import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_add_dialog.dart';
import '../widgets/log_screen_widgets.dart';

class FoodLogScreen extends StatefulWidget {
  final Map<String, DayEntry> dayEntries;
  final Function(Map<String, DayEntry>) onSave;

  const FoodLogScreen({
    Key? key,
    required this.dayEntries,
    required this.onSave,
  }) : super(key: key);

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  DateTime _selectedDate = DateTime.now();
  late ScrollController _calendarScrollController;
  String get _selectedDateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  DayEntry _getOrCreateEntry() {
    if (!widget.dayEntries.containsKey(_selectedDateKey)) {
      widget.dayEntries[_selectedDateKey] = DayEntry(
        date: _selectedDate,
        foods: [],
      );
    }
    return widget.dayEntries[_selectedDateKey]!;
  }

  void _goToPrevDay() {
    _changeDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    _changeDate(_selectedDate.add(const Duration(days: 1)));
  }

  void _saveChanges() {
    widget.onSave(widget.dayEntries);
    setState(() {});
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    // 1. Vibración sutil al cambiar de día
    HapticFeedback.lightImpact();

    // 2. Lógica de Scroll Suave
    // Calculamos el índice relativo a "Hoy" (que es el índice 30)
    final int dayDifference = date.difference(DateTime.now()).inDays;
    final int targetIndex = 30 + dayDifference;

    // Ancho de la tarjeta (55) + márgenes (12) = 67.0
    const double itemWidth = 67.0;

    // Calculamos la posición para centrar el elemento
    // El '- 170' es un ajuste para centrarlo según el ancho promedio de pantalla
    if (_calendarScrollController.hasClients) {
      _calendarScrollController.animateTo(
        (targetIndex * itemWidth) - 170,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack, // Un efecto de rebote suave al final
      );
    }
  }

  void _showAddFoodDialog(DayEntry entry) {
    showDialog(
      context: context,
      builder: (context) => QuickAddDialog(
        initialMood: entry.mood,
        initialEnergy: entry.energyLevel,
        initialTags: entry.tags,
        onAdd: (type, {energy, health, mood, name, tags, time}) {
          setState(() {
            if (type == 'food_save') {
              entry.foods.add(
                FoodItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name!,
                  time: time!,
                ),
              );
            } else if (type == 'mood_save') {
              entry.mood = mood;
            } else if (type == 'energy_save') {
              entry.energyLevel = energy;
            } else if (type == 'tags_save') {
              entry.tags = tags ?? [];
            }
            _saveChanges();
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    const double itemWidth = 67.0;
    _calendarScrollController = ScrollController(
      initialScrollOffset: (30 * itemWidth) - (200),
    );
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _getOrCreateEntry();
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_selectedDate, now);
    final isPast = _selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );
    final isFuture = _selectedDate.isAfter(now) && !isToday;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                size: 28,
                color: AppTheme.primary,
              ),
              onPressed: _goToPrevDay,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat(
                    'EEEE',
                    'es_ES',
                  ).format(_selectedDate).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('d MMMM yyyy', 'es_ES').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.chevron_right,
                size: 28,
                color: AppTheme.primary,
              ),
              onPressed: _goToNextDay,
            ),
          ],
        ),
        actions: [
          if (!isToday)
            IconButton(
              icon: const Icon(Icons.today, color: AppTheme.primary),
              onPressed: () => _changeDate(now),
            ),
        ],
      ),
      body: Column(
        children: [
          LogWidgets.calendarStrip(
            selectedDate: _selectedDate,
            onDateSelected: _changeDate,
            scrollController: _calendarScrollController,
          ),

          if (isPast)
            LogWidgets.statusTag("Editando día pasado", AppTheme.warning),
          if (isFuture)
            LogWidgets.statusTag("Planificando futuro", AppTheme.primary),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),

                LogWidgets.sectionHeader("Estado de ánimo"),
                LogWidgets.moodSelector(
                  currentMood: entry.mood,
                  onMoodSelected: (label) {
                    entry.mood = label;
                    _saveChanges();
                  },
                ),

                const SizedBox(height: 24),
                LogWidgets.sectionHeader("Nivel de energía"),
                LogWidgets.energyTracker(
                  currentEnergy: entry.energyLevel ?? 0,
                  onEnergySelected: (level) {
                    entry.energyLevel = level;
                    _saveChanges();
                  },
                ),

                const SizedBox(height: 24),
                LogWidgets.sectionHeader("Factores del día (Tags)"),
                LogWidgets.tagsModule(
                  selectedTags: entry.tags,
                  onTagToggled: (tag, isSelected) {
                    setState(() {
                      entry.tags = List<String>.from(entry.tags);
                      isSelected ? entry.tags.add(tag) : entry.tags.remove(tag);
                    });
                    _saveChanges();
                  },
                ),

                const SizedBox(height: 24),
                LogWidgets.sectionHeader("Registro de comidas"),
                LogWidgets.foodSection(
                  context: context,
                  entry: entry,
                  onAddTap: () => _showAddFoodDialog(entry),
                  onDeleteFood: (food) {
                    entry.foods.remove(food);
                    _saveChanges();
                  },
                ),

                const SizedBox(height: 24),
                LogWidgets.sectionHeader("Salud y Reacciones"),
                LogWidgets.reactionToggle(
                  hadReaction: entry.hadReaction,
                  onChanged: (val) {
                    entry.hadReaction = val;
                    _saveChanges();
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
