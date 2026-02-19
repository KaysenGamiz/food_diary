import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/day_card.dart';
import '../widgets/weekly_status_banner.dart';

class DiaryScreen extends StatelessWidget {
  final Map<String, DayEntry> dayEntries;
  final Function(DayEntry) onUpdateDay;
  final Function(String) onDeleteDay;

  const DiaryScreen({
    super.key,
    required this.dayEntries,
    required this.onUpdateDay,
    required this.onDeleteDay,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDays = dayEntries.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Diario'), elevation: 0),
      body: sortedDays.isEmpty
          ? _buildEmptyState()
          : ListView(
              // Cambiamos a ListView para scroll fluido con el banner
              children: [
                WeeklyStatusBanner(
                  days: sortedDays,
                ), // ¡Aquí está tu widget modularizado!
                ListView.builder(
                  shrinkWrap: true, // Importante dentro de otro ListView
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DayCard(
                        day: day,
                        onUpdate: onUpdateDay,
                        onDelete: () => onDeleteDay(day.dateKey),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay registros todavía',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Toca el botón "+" para registrar tu primera comida o estado de ánimo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
