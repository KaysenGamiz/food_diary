import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/day_card.dart';

class DiaryScreen extends StatelessWidget {
  final Map<String, DayEntry> dayEntries;
  final Function(DayEntry) onUpdateDay;
  final Function(String) onDeleteDay;

  const DiaryScreen({
    Key? key,
    required this.dayEntries,
    required this.onUpdateDay,
    required this.onDeleteDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedDays = dayEntries.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Diario')),
      body: sortedDays.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay días registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ve a Food Log para empezar',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDays.length,
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                return DayCard(
                  day: day,
                  onUpdate: onUpdateDay,
                  onDelete: () => onDeleteDay(day.dateKey),
                );
              },
            ),
    );
  }
}
