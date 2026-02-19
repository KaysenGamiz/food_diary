import 'package:flutter/material.dart';
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

  void _saveChanges() {
    widget.onSave(widget.dayEntries);
    setState(() {});
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    if (DateUtils.isSameDay(date, DateTime.now())) {
      _calendarScrollController.animateTo(
        (30 * 67.0) - 170,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
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
        title: Column(
          children: [
            Text(
              DateFormat('EEEE', 'es_ES').format(_selectedDate).toUpperCase(),
              style: const TextStyle(fontSize: 16, letterSpacing: 1.5),
            ),
            Text(
              DateFormat('d MMMM yyyy', 'es_ES').format(_selectedDate),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
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
