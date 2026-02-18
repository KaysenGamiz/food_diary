import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum QuickAddType { food, mood, energy, tags, health }

extension QuickAddTypeExtension on QuickAddType {
  String get title {
    switch (this) {
      case QuickAddType.food:
        return "Comida";
      case QuickAddType.mood:
        return "Mood";
      case QuickAddType.energy:
        return "Energía";
      case QuickAddType.tags:
        return "Tags";
      case QuickAddType.health:
        return "Salud";
    }
  }

  IconData get icon {
    switch (this) {
      case QuickAddType.food:
        return Icons.restaurant;
      case QuickAddType.mood:
        return Icons.mood;
      case QuickAddType.energy:
        return Icons.bolt;
      case QuickAddType.tags:
        return Icons.local_offer_outlined;
      case QuickAddType.health:
        return Icons.healing_outlined;
    }
  }

  Color get color {
    switch (this) {
      case QuickAddType.food:
        return AppTheme.primary;
      case QuickAddType.mood:
        return Colors.amber;
      case QuickAddType.energy:
        return Colors.yellow;
      case QuickAddType.tags:
        return AppTheme.tagActivity;
      case QuickAddType.health:
        return AppTheme.danger;
    }
  }
}
