import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../theme/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  final Map<String, DayEntry> dayEntries;

  const AnalysisScreen({Key? key, required this.dayEntries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // FILTRO CLAVE: Solo días pasados (o hoy) que tengan comida
    final validEntries = dayEntries.values.where((day) {
      final isPastOrToday = day.date.isBefore(
        today.add(const Duration(days: 1)),
      );
      final hasFood = day.foods.isNotEmpty;
      return isPastOrToday && hasFood;
    }).toList();

    // Días con reacción (ya están filtrados implícitamente por tener reacción)
    final daysWithReaction =
        validEntries.where((day) => day.hadReaction).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (validEntries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análisis')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 80,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Datos insuficientes',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registra comidas en días pasados\npara ver el análisis',
                style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Análisis de alimentos (usando validEntries para la frecuencia total)
    final foodFrequency = <String, int>{};
    final foodAppearances = <String, List<DateTime>>{};
    final allFoods = <String, int>{};

    for (var day in daysWithReaction) {
      for (var food in day.foods) {
        final foodName = food.name.toLowerCase().trim();
        foodFrequency[foodName] = (foodFrequency[foodName] ?? 0) + 1;
        foodAppearances.putIfAbsent(foodName, () => []);
        foodAppearances[foodName]!.add(day.date);
      }
    }

    for (var day in validEntries) {
      for (var food in day.foods) {
        final foodName = food.name.toLowerCase().trim();
        allFoods[foodName] = (allFoods[foodName] ?? 0) + 1;
      }
    }

    final sortedFoods = foodFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Análisis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(daysWithReaction.length, validEntries.length),

          const SizedBox(height: 24),
          _buildSectionHeader(),
          const SizedBox(height: 16),

          ...sortedFoods.take(15).map((entry) {
            final totalAppearances = allFoods[entry.key] ?? entry.value;
            final reactionRate = (entry.value / totalAppearances * 100);
            final dates = foodAppearances[entry.key]!;

            return _buildFoodAnalysisCard(
              entry.key,
              entry.value,
              reactionRate,
              totalAppearances,
              dates,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int reactionsCount, int totalDays) {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppTheme.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumen',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              'Días con reacción',
              '$reactionsCount',
              Icons.warning_rounded,
              AppTheme.danger,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Total de días',
              '$totalDays',
              Icons.calendar_today,
              AppTheme.primary,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              'Tasa de reacción',
              '${((reactionsCount / totalDays) * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              AppTheme.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Icon(Icons.search, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Alimentos Sospechosos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodAnalysisCard(
    String foodName,
    int reactionCount,
    double reactionRate,
    int totalAppearances,
    List<DateTime> dates,
  ) {
    Color getRiskColor() {
      if (reactionRate > 75) return AppTheme.danger;
      if (reactionRate > 50) return AppTheme.warning;
      return Colors.yellow[700]!;
    }

    return Card(
      color: reactionRate > 50
          ? AppTheme.danger.withOpacity(0.05)
          : AppTheme.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: reactionRate > 50
            ? BorderSide(color: AppTheme.danger.withOpacity(0.2), width: 1)
            : BorderSide.none,
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: getRiskColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$reactionCount',
                style: TextStyle(
                  color: getRiskColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            foodName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$reactionCount día${reactionCount > 1 ? "s" : ""} • ${reactionRate.toStringAsFixed(0)}% tasa',
              style: TextStyle(
                color: reactionRate > 50
                    ? getRiskColor()
                    : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Icon(
            reactionRate > 75
                ? Icons.error
                : reactionRate > 50
                ? Icons.warning_rounded
                : Icons.info,
            color: getRiskColor(),
            size: 24,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de apariciones: $totalAppearances veces',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fechas con reacción:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dates.map(
                    (date) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: getRiskColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('d MMM yyyy', 'es_ES').format(date),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
