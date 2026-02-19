import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnalysisWidgets {
  // Selector de rango de tiempo (7D, 30D, Todo)
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
