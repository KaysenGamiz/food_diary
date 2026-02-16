import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../theme/app_theme.dart';

class DayDetailsDialog extends StatelessWidget {
  final DayEntry day;
  final Function(DayEntry) onUpdate;

  const DayDetailsDialog({Key? key, required this.day, required this.onUpdate})
    : super(key: key);

  void _toggleReaction(BuildContext context) {
    final controller = TextEditingController(text: day.reactionNotes ?? '');
    bool hadReaction = day.hadReaction;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Marcar Reacción',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text(
                  '¿Hubo reacción alérgica?',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                subtitle: const Text(
                  'Marca si hubo síntomas este día',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                value: hadReaction,
                activeColor: AppTheme.danger,
                onChanged: (value) {
                  setState(() {
                    hadReaction = value;
                  });
                },
              ),
              if (hadReaction) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Síntomas',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    hintText: 'Ej: picazón, hinchazón, erupciones',
                    hintStyle: const TextStyle(color: AppTheme.textTertiary),
                    filled: true,
                    fillColor: AppTheme.darkBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () {
                day.hadReaction = hadReaction;
                day.reactionNotes = hadReaction ? controller.text : null;
                onUpdate(day);
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('d MMMM yyyy', 'es_ES').format(day.date),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                day.hadReaction
                    ? Icons.warning_rounded
                    : Icons.check_circle_rounded,
                size: 16,
                color: day.hadReaction ? AppTheme.danger : AppTheme.success,
              ),
              const SizedBox(width: 6),
              Text(
                day.hadReaction ? 'Con reacción' : 'Sin reacción',
                style: TextStyle(
                  fontSize: 13,
                  color: day.hadReaction ? AppTheme.danger : AppTheme.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (day.hadReaction && day.reactionNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.medical_information,
                      color: AppTheme.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.reactionNotes!,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Comidas del día',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (day.foods.isEmpty)
              const Text(
                'No hay comidas registradas',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              )
            else
              ...day.foods.map(
                (food) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        food.time.format(context),
                        style: const TextStyle(
                          fontSize: 12,
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
      actions: [
        TextButton.icon(
          onPressed: () => _toggleReaction(context),
          icon: Icon(
            day.hadReaction ? Icons.check_circle : Icons.warning,
            size: 18,
            color: day.hadReaction ? AppTheme.success : AppTheme.danger,
          ),
          label: Text(
            day.hadReaction ? 'Quitar reacción' : 'Marcar reacción',
            style: TextStyle(
              color: day.hadReaction ? AppTheme.success : AppTheme.danger,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
