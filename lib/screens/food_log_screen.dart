import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_add_dialog.dart';

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

  String get _selectedDateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  // Helper para obtener o inicializar la entrada del día seleccionado
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
    setState(() {}); // Refresca la UI
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
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
          _buildCalendarStrip(),
          if (isPast) _buildStatusTag("Editando día pasado", AppTheme.warning),
          if (isFuture)
            _buildStatusTag("Planificando futuro", AppTheme.primary),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                _buildSectionHeader("Estado de ánimo"),
                _buildMoodSelector(entry),

                const SizedBox(height: 24),
                _buildSectionHeader("Nivel de energía"),
                _buildEnergyTracker(entry),

                const SizedBox(height: 24),
                _buildSectionHeader("Registro de comidas"),
                _buildFoodSection(entry),

                const SizedBox(height: 24),
                _buildSectionHeader("Salud"),
                _buildReactionToggle(entry),
                const SizedBox(height: 100), // Espacio para el FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => QuickAddDialog(
            onAdd: (name, time) {
              final newItem = FoodItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                time: time,
              );
              entry.foods.add(newItem);
              _saveChanges();
            },
          ),
        ),
        label: const Text("Comida"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textTertiary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMoodSelector(DayEntry entry) {
    final moods = [
      {'label': 'Mal', 'emoji': '😡'},
      {'label': 'Triste', 'emoji': '😔'},
      {'label': 'Neutral', 'emoji': '😐'},
      {'label': 'Bien', 'emoji': '😊'},
      {'label': 'Excelente', 'emoji': '🤩'},
    ];

    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: moods.map((m) {
            final isSelected = entry.mood == m['label'];
            return GestureDetector(
              onTap: () {
                entry.mood = m['label'] as String;
                _saveChanges();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  m['emoji'] as String,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEnergyTracker(DayEntry entry) {
    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isActive = (entry.energyLevel ?? 0) >= level;
                return GestureDetector(
                  onTap: () {
                    entry.energyLevel = level;
                    _saveChanges();
                  },
                  child: Icon(
                    Icons.bolt,
                    size: 35,
                    color: isActive
                        ? Colors.yellow[700]
                        : AppTheme.textTertiary.withOpacity(0.2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Agotado",
                  style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                ),
                Text(
                  "Enérgico",
                  style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSection(DayEntry entry) {
    if (entry.foods.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppTheme.textTertiary.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: const Center(
          child: Text(
            "Sin registros de comida",
            style: TextStyle(color: AppTheme.textTertiary),
          ),
        ),
      );
    }

    return Column(
      children: entry.foods.map((food) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(
              food.time.format(context),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            title: Text(food.name),
            trailing: IconButton(
              icon: const Icon(
                Icons.close,
                size: 20,
                color: AppTheme.textTertiary,
              ),
              onPressed: () {
                entry.foods.remove(food);
                _saveChanges();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReactionToggle(DayEntry entry) {
    return Card(
      color: entry.hadReaction
          ? AppTheme.danger.withOpacity(0.15)
          : AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: const Text("¿Reacción alérgica/malestar?"),
        value: entry.hadReaction,
        activeColor: AppTheme.danger,
        onChanged: (val) {
          entry.hadReaction = val;
          _saveChanges();
        },
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 60, // Aumentado para dar más margen de navegación
        itemBuilder: (context, index) {
          final date = DateTime.now()
              .subtract(const Duration(days: 30))
              .add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () => _changeDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'es_ES').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1)),
      child: Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
