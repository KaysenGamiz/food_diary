import 'package:flutter/material.dart';

enum NavTab { diary, log, add, analysis, settings }

extension NavTabExtension on NavTab {
  String get label {
    switch (this) {
      case NavTab.diary:
        return 'Diario';
      case NavTab.log:
        return 'Log';
      case NavTab.add:
        return 'Añadir';
      case NavTab.analysis:
        return 'Análisis';
      case NavTab.settings:
        return 'Ajustes';
    }
  }

  IconData get icon => {
    NavTab.diary: Icons.calendar_month_outlined,
    NavTab.log: Icons.restaurant_outlined,
    NavTab.add: Icons.add_circle,
    NavTab.analysis: Icons.analytics_outlined,
    NavTab.settings: Icons.settings_outlined,
  }[this]!;

  IconData get selectedIcon => {
    NavTab.diary: Icons.calendar_month,
    NavTab.log: Icons.restaurant,
    NavTab.add: Icons.add_circle,
    NavTab.analysis: Icons.analytics,
    NavTab.settings: Icons.settings,
  }[this]!;
}
