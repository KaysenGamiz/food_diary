import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../models/mood_model.dart'; // Importamos el nuevo modelo centralizado
import '../theme/app_theme.dart';
import 'day_details_dialog.dart';

class DayCard extends StatelessWidget {
  final DayEntry day;
  final Function(DayEntry) onUpdate;
  final VoidCallback onDelete;

  const DayCard({
    Key? key,
    required this.day,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasAlert = day.hadReaction;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasAlert ? 4 : 1,
      color: hasAlert ? const Color(0xFF2D1F1F) : AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasAlert
              ? AppTheme.danger.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                DayDetailsDialog(day: day, onUpdate: onUpdate),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMoodAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM', 'es_ES').format(day.date),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildQuickMetrics(),
                      ],
                    ),
                  ),
                  if (hasAlert) _buildReactionBadge(),
                ],
              ),
              if (day.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTagsWrap(),
              ],
              if (hasAlert && day.reactionNotes != null) ...[
                const SizedBox(height: 12),
                _buildReactionNotes(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.darkCardElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      // CAMBIO ESPECÍFICO: Usamos MoodData para obtener el emoji dinámicamente
      child: Text(
        MoodData.getEmoji(day.mood),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildQuickMetrics() {
    return Row(
      children: [
        Text(
          '${day.foods.length} comida${day.foods.length != 1 ? "s" : ""}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        if (day.energyLevel != null) ...[
          const SizedBox(width: 8),
          const Text("•", style: TextStyle(color: AppTheme.textTertiary)),
          const SizedBox(width: 8),
          const Icon(Icons.bolt, size: 14, color: Colors.amber),
          Text(
            '${day.energyLevel}',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReactionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'REACCIÓN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildTagsWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: day.tags.map((tag) {
        final color = AppTheme.getTagColor(tag);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIconForTag(tag), size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                tag,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForTag(String tag) {
    switch (tag) {
      case 'Gimnasio':
        return Icons.fitness_center;
      case 'Café':
        return Icons.coffee;
      case 'Alcohol':
        return Icons.local_bar;
      case 'Estrés':
        return Icons.psychology;
      case 'Medicamento':
        return Icons.medication;
      default:
        return Icons.local_offer;
    }
  }

  Widget _buildReactionNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        day.reactionNotes!,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textPrimary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
