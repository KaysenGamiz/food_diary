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

  // Genera la llave yyyy-MM-dd para buscar en el mapa
  String get _selectedDateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _addFood(String name, TimeOfDay time) {
    setState(() {
      final newItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        time: time,
      );

      if (widget.dayEntries.containsKey(_selectedDateKey)) {
        widget.dayEntries[_selectedDateKey]!.foods.add(newItem);
      } else {
        widget.dayEntries[_selectedDateKey] = DayEntry(
          date: _selectedDate,
          foods: [newItem],
        );
      }
    });
    widget.onSave(widget.dayEntries);
  }

  void _toggleReaction(bool value) {
    setState(() {
      if (widget.dayEntries.containsKey(_selectedDateKey)) {
        widget.dayEntries[_selectedDateKey]!.hadReaction = value;
      } else {
        widget.dayEntries[_selectedDateKey] = DayEntry(
          date: _selectedDate,
          hadReaction: value,
          foods: [],
        );
      }
    });
    widget.onSave(widget.dayEntries);
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = widget.dayEntries[_selectedDateKey];
    final bool hasReaction = currentEntry?.hadReaction ?? false;
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_selectedDate, now);
    final isPast = _selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );
    final isFuture = _selectedDate.isAfter(now) && !isToday;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(DateFormat('EEEE', 'es_ES').format(_selectedDate)),
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
            TextButton.icon(
              onPressed: () => _changeDate(now),
              icon: const Icon(Icons.today, color: AppTheme.primary),
              label: const Text(
                'Hoy',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          if (isPast) _buildStatusTag("Editing past day", AppTheme.warning), //
          if (isFuture)
            _buildStatusTag("Planning future day", AppTheme.primary), //

          _buildReactionToggle(hasReaction),

          Expanded(
            child: currentEntry == null || currentEntry.foods.isEmpty
                ? _buildEmptyState()
                : _buildFoodList(currentEntry.foods),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => QuickAddDialog(onAdd: _addFood),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30, // Muestra 30 días alrededor de la fecha
        itemBuilder: (context, index) {
          final date = DateTime.now()
              .subtract(Duration(days: 15))
              .add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () => _changeDate(date),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: AppTheme.primary) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E', 'es_ES').format(date)[0].toUpperCase()),
                  Text(
                    date.day.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: color.withOpacity(0.1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildReactionToggle(bool hasReaction) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: hasReaction ? AppTheme.danger.withOpacity(0.2) : AppTheme.darkCard,
      child: SwitchListTile(
        title: const Text("¿Hubo reacción hoy?"),
        secondary: Icon(
          Icons.warning_amber_rounded,
          color: hasReaction ? AppTheme.danger : AppTheme.textTertiary,
        ),
        value: hasReaction,
        onChanged: _toggleReaction,
        activeColor: AppTheme.danger,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            "No hay comidas registradas",
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const Text(
            "Toca los botones + para agregar",
            style: TextStyle(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> foods) {
    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return ListTile(
          leading: const Icon(Icons.restaurant, color: AppTheme.primary),
          title: Text(food.name),
          subtitle: Text(food.time.format(context)),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                widget.dayEntries[_selectedDateKey]?.foods.removeAt(index);
              });
              widget.onSave(widget.dayEntries);
            },
          ),
        );
      },
    );
  }
}
