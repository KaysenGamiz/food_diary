import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/day_entry.dart';
import '../models/food_item.dart';
import '../models/mood_model.dart';
import '../models/tag_model.dart';

class LogWidgets {
  static Widget calendarStrip({
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
    required ScrollController scrollController,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 60,
        itemBuilder: (context, index) {
          final date = DateTime.now()
              .subtract(const Duration(days: 30))
              .add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () => onDateSelected(date),
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
                          offset: const Offset(0, 4),
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  // --- SECCIÓN DE COMIDAS (NUEVO) ---
  static Widget foodSection({
    required BuildContext context,
    required DayEntry entry,
    required VoidCallback onAddTap,
    required Function(FoodItem) onDeleteFood,
  }) {
    if (entry.foods.isEmpty) {
      return InkWell(
        onTap: onAddTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppTheme.textTertiary.withOpacity(0.2),
              width: 2,
            ),
            color: AppTheme.darkCard.withOpacity(0.5),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppTheme.primary.withOpacity(0.6),
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                "Toca para registrar tu primera comida",
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...entry.foods.map(
          (food) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppTheme.darkCard,
            child: ListTile(
              leading: Text(
                food.time.format(context),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              title: Text(
                food.name,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
                onPressed: () => onDeleteFood(food),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAddTap,
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Añadir otra comida"),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
        ),
      ],
    );
  }

  static Widget sectionHeader(String title) {
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

  static Widget moodSelector({
    required String? currentMood,
    required Function(String) onMoodSelected,
  }) {
    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: MoodData.all.map((m) {
            final isSelected = currentMood == m.label;
            return GestureDetector(
              onTap: () => onMoodSelected(m.label),
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
                child: Text(m.emoji, style: const TextStyle(fontSize: 26)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static Widget energyTracker({
    required int currentEnergy,
    required Function(int) onEnergySelected,
  }) {
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
                final isActive = currentEnergy >= level;
                return GestureDetector(
                  onTap: () => onEnergySelected(level),
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
                  "Baja",
                  style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                ),
                Text(
                  "Alta",
                  style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget tagsModule({
    required List<String> selectedTags,
    required Function(String, bool) onTagToggled,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TagData.all.map((tag) {
        final isSelected = selectedTags.contains(tag.name);
        return FilterChip(
          label: Text(tag.name),
          selected: isSelected,
          onSelected: (val) => onTagToggled(tag.name, val),
          selectedColor: tag.color.withOpacity(0.2),
          checkmarkColor: tag.color,
          labelStyle: TextStyle(
            color: isSelected ? tag.color : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? tag.color : Colors.transparent,
              width: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  static Widget reactionToggle({
    required bool hadReaction,
    required Function(bool) onChanged,
  }) {
    return Card(
      color: hadReaction
          ? AppTheme.danger.withOpacity(0.15)
          : AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: const Text("¿Hubo malestar hoy?"),
        subtitle: const Text(
          "Marca si sentiste síntomas inusuales",
          style: TextStyle(fontSize: 11),
        ),
        value: hadReaction,
        activeColor: AppTheme.danger,
        onChanged: onChanged,
      ),
    );
  }

  static Widget statusTag(String text, Color color) {
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
