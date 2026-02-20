import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnalysisWidgets {
  // Selector de rango de tiempo (7D, 30D, 3M, Todo)
  static Widget rangeSelector({
    required int currentRange,
    required Function(int) onSelected,
  }) {
    final options = {7: "7D", 30: "30D", 90: "3M", 0: "Todo"};

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.entries.map((e) {
          bool isSelected = currentRange == e.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (_) => onSelected(e.key),
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.darkCard,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget summaryCard({
    required int reactionsCount,
    required int totalDays,
  }) {
    final double rate = totalDays > 0 ? (reactionsCount / totalDays) : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _largeStat("Días", "$totalDays", AppTheme.primary),
              _largeStat("Reacciones", "$reactionsCount", AppTheme.danger),
              _largeStat(
                "Tasa",
                "${(rate * 100).toStringAsFixed(0)}%",
                AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: AppTheme.darkBg,
              color: rate > 0.5 ? AppTheme.danger : AppTheme.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _largeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  static Widget infoBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static Widget tagsRiskAnalysis(Map<String, int> tagFreq) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagFreq.entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, size: 14, color: AppTheme.danger),
              const SizedBox(width: 4),
              Text(
                e.key,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Text(
                "${e.value}",
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget moodRadarChart(Map<String, int> moodCounts) {
    // 1. Asegurar que siempre existan las 5 categorías para mantener la forma de pentágono
    final Map<String, double> fullData = {
      'Excelente': (moodCounts['Excelente'] ?? 0).toDouble(),
      'Bien': (moodCounts['Bien'] ?? 0).toDouble(),
      'Neutral': (moodCounts['Neutral'] ?? 0).toDouble(),
      'Triste': (moodCounts['Triste'] ?? 0).toDouble(),
      'Mal': (moodCounts['Mal'] ?? 0).toDouble(),
    };

    final List<String> titles = fullData.keys.toList();
    final List<RadarEntry> entries = fullData.values
        .map((val) => RadarEntry(value: val))
        .toList();

    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20), // Padding uniforme
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.05)),
      ),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppTheme.primary.withOpacity(0.25),
              borderColor: AppTheme.primary,
              entryRadius: 3,
              dataEntries: entries,
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(color: Colors.white10, width: 1),
          gridBorderData: const BorderSide(color: Colors.white10, width: 1),
          tickCount: 3,
          tickBorderData: const BorderSide(color: Colors.white10),
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),

          titlePositionPercentageOffset: 0.15,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          getTitle: (index, angle) {
            final title = titles[index];
            if (index == 0) return RadarChartTitle(text: title);
            return RadarChartTitle(text: title);
          },
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  // --- MÉTODO AUXILIAR PARA LA LISTA DE ALIMENTOS ---
  // Llama a este método desde tu ListView en AnalysisScreen
  static Widget foodRiskTile({
    required String name,
    required int reactionCount,
    required int totalAppearances,
    required Color riskColor,
  }) {
    final double rateDouble = (reactionCount / totalAppearances * 100);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: riskColor.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: riskColor.withOpacity(0.3), width: 1),
        ),
        child: Center(
          child: Text(
            "$reactionCount",
            style: TextStyle(
              color: riskColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
        "Aparece en $totalAppearances registros",
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
            height: 4,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
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

  static Widget sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
