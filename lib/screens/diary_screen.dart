import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../models/quick_add_model.dart'; // Asegúrate de que la ruta sea correcta
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
      appBar: AppBar(title: const Text('Mi Diario'), elevation: 0),
      body: sortedDays.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildDynamicSummary(sortedDays),
                Expanded(
                  child: ListView.builder(
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
                ),
              ],
            ),
    );
  }

  Widget _buildDynamicSummary(List<DayEntry> days) {
    final last7Days = days.take(7).toList();
    final highEnergyDays = last7Days
        .where((d) => (d.energyLevel ?? 0) >= 4)
        .length;
    final reactions = last7Days.where((d) => d.hadReaction == true).length;

    String message;
    IconData icon;
    Color statusColor = AppTheme.primary;

    if (reactions > 2) {
      message =
          "Has tenido malestar en $reactions días. ¡Revisa tus tags de hoy!";
      icon = Icons.warning_amber_rounded;
      statusColor = AppTheme.danger;
    } else if (highEnergyDays >= 4) {
      message =
          "¡Genial! Has tenido $highEnergyDays días con energía alta esta semana.";
      icon = Icons.bolt;
    } else if (days.length < 3) {
      message =
          "¡Vas por buen camino! Sigue registrando para ver tus tendencias.";
      icon = Icons.auto_awesome;
    } else {
      message = "Tu energía promedio esta semana es estable. ¡Sigue así!";
      icon = Icons.insights;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ESTADO SEMANAL",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: ESTADO VACÍO ---
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
