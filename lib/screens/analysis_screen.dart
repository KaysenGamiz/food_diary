import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/analysis_widgets.dart';

class AnalysisScreen extends StatefulWidget {
  final Map<String, DayEntry> dayEntries;

  const AnalysisScreen({Key? key, required this.dayEntries}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _daysRange = 30;

  Color _getRiskColor(double rate) {
    if (rate >= 70) return AppTheme.danger;
    if (rate >= 40) return AppTheme.warning;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutOffDate = today.subtract(Duration(days: _daysRange));

    // 1. FILTRADO
    final validEntries = widget.dayEntries.values.where((day) {
      final isPastOrToday = day.date.isBefore(
        today.add(const Duration(days: 1)),
      );
      final isInRange =
          _daysRange == 0 ||
          day.date.isAfter(cutOffDate) ||
          day.date.isAtSameMomentAs(cutOffDate);
      return isPastOrToday && day.foods.isNotEmpty && isInRange;
    }).toList();

    if (validEntries.isEmpty) return _buildEmptyState();

    // 2. PROCESAMIENTO
    final daysWithReaction = validEntries
        .where((day) => day.hadReaction)
        .toList();
    final moodCounts = <String, int>{};
    final tagFreqInReactions = <String, int>{};
    double totalEnergy = 0;
    int energyCount = 0;
    final foodFreqInReactions = <String, int>{};
    final totalFoodAppearances = <String, int>{};

    for (var day in validEntries) {
      if (day.mood != null && day.mood!.isNotEmpty) {
        moodCounts[day.mood!] = (moodCounts[day.mood!] ?? 0) + 1;
      }
      if (day.energyLevel != null) {
        totalEnergy += day.energyLevel!;
        energyCount++;
      }
      for (var food in day.foods) {
        final name = food.name.toLowerCase().trim();
        totalFoodAppearances[name] = (totalFoodAppearances[name] ?? 0) + 1;
        if (day.hadReaction) {
          foodFreqInReactions[name] = (foodFreqInReactions[name] ?? 0) + 1;
        }
      }
      if (day.hadReaction) {
        for (var tag in day.tags) {
          tagFreqInReactions[tag] = (tagFreqInReactions[tag] ?? 0) + 1;
        }
      }
    }

    final avgEnergy = energyCount > 0 ? totalEnergy / energyCount : 0.0;
    final topMood = moodCounts.isEmpty
        ? "N/A"
        : (moodCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    final sortedFoods = foodFreqInReactions.entries.toList()
      ..sort(
        (a, b) => (b.value / totalFoodAppearances[b.key]!).compareTo(
          a.value / totalFoodAppearances[a.key]!,
        ),
      );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Análisis'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnalysisWidgets.rangeSelector(
            currentRange: _daysRange,
            onSelected: (val) => setState(() => _daysRange = val),
          ),
          const SizedBox(height: 16),

          AnalysisWidgets.summaryCard(
            reactionsCount: daysWithReaction.length,
            totalDays: validEntries.length,
          ),

          const SizedBox(height: 24),
          AnalysisWidgets.sectionHeader(
            "Bienestar General",
            Icons.favorite_border_rounded,
          ),
          Row(
            children: [
              Expanded(
                child: AnalysisWidgets.infoBox(
                  label: "Ánimo Común",
                  value: topMood,
                  icon: Icons.emoji_emotions_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnalysisWidgets.infoBox(
                  label: "Energía Promedio",
                  value: avgEnergy.toStringAsFixed(1),
                  icon: Icons.bolt,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          // --- GRÁFICA CON FL_CHART ---
          if (moodCounts.length >= 3)
            AnalysisWidgets.moodRadarChart(moodCounts)
          else if (moodCounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Registra al menos 3 tipos de ánimos para comparar.",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ),

          if (tagFreqInReactions.isNotEmpty) ...[
            const SizedBox(height: 32),
            AnalysisWidgets.sectionHeader("Factores en Reacciones", Icons.tag),
            AnalysisWidgets.tagsRiskAnalysis(tagFreqInReactions),
          ],

          const SizedBox(height: 32),
          AnalysisWidgets.sectionHeader(
            "Alimentos Sospechosos",
            Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 8),
          if (sortedFoods.isEmpty)
            const Text(
              "Sin alimentos con riesgo.",
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            ...sortedFoods
                .take(10)
                .map(
                  (e) =>
                      _foodTile(e.key, e.value, totalFoodAppearances[e.key]!),
                ),
        ],
      ),
    );
  }

  // (Mantenemos _foodTile y _buildEmptyState igual que antes...)
  Widget _foodTile(String name, int reactionCount, int total) {
    final double rateDouble = (reactionCount / total * 100);
    final Color riskColor = _getRiskColor(rateDouble);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: riskColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "$reactionCount",
            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "En $total registros",
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${rateDouble.toStringAsFixed(0)}% riesgo",
            style: TextStyle(
              color: riskColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (rateDouble / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Análisis')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnalysisWidgets.rangeSelector(
              currentRange: _daysRange,
              onSelected: (val) => setState(() => _daysRange = val),
            ),
            const Spacer(),
            const Icon(
              Icons.analytics_outlined,
              size: 60,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              "Sin datos para este periodo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
