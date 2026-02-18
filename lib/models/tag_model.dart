import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TagData {
  final String name;
  final IconData icon;
  final Color color;

  const TagData({required this.name, required this.icon, required this.color});

  // Lista única de la verdad para toda la app
  static List<TagData> get all => [
    TagData(name: 'Café', icon: Icons.coffee, color: AppTheme.tagSubstance),
    TagData(
      name: 'Alcohol',
      icon: Icons.local_bar,
      color: AppTheme.tagSubstance,
    ),
    TagData(
      name: 'Gimnasio',
      icon: Icons.fitness_center,
      color: AppTheme.tagActivity,
    ),
    TagData(name: 'Estrés', icon: Icons.psychology, color: AppTheme.tagHealth),
    TagData(name: 'Poco Sueño', icon: Icons.bedtime, color: AppTheme.tagHealth),
    TagData(name: 'Ayuno', icon: Icons.timer, color: AppTheme.tagProtocol),
    TagData(name: 'Viaje', icon: Icons.flight, color: AppTheme.tagLifestyle),
    TagData(
      name: 'Medicamento',
      icon: Icons.medication,
      color: AppTheme.tagProtocol,
    ),
  ];

  // Helper para recuperar la data de un tag solo por su nombre
  static TagData getByName(String name) {
    return all.firstWhere(
      (t) => t.name == name,
      orElse: () =>
          TagData(name: name, icon: Icons.local_offer, color: AppTheme.primary),
    );
  }
}
