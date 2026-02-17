import 'package:flutter/material.dart';

class AppTheme {
  // Dark Colors
  static const darkBg = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF2A2A2A);
  static const darkCardElevated = Color(0xFF333333);
  static const darkDivider = Color(0xFF404040);

  // Accent Colors
  static const primary = Color(0xFF4CAF50);
  static const success = Color(0xFF66BB6A);
  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFE53935);

  // --- Paleta para Tags / Categorías ---
  static const tagActivity = Color(0xFF42A5F5); // Azul
  static const tagSubstance = Color(0xFFFFB74D); // Ámbar/Naranja
  static const tagHealth = Color(0xFFFF5252); // Rojo
  static const tagProtocol = Color(0xFFB39DDB); // Morado
  static const tagLifestyle = Color(0xFF4DB6AC); // Teal

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
  static const textTertiary = Color(0xFF808080);

  static Color getTagColor(String tag) {
    switch (tag) {
      case 'Gimnasio':
        return tagActivity;
      case 'Café':
      case 'Alcohol':
        return tagSubstance;
      case 'Estrés':
      case 'Poco Sueño':
        return tagHealth;
      case 'Ayuno':
      case 'Medicamento':
        return tagProtocol;
      case 'Viaje':
        return tagLifestyle;
      default:
        return primary;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkDivider,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: success,
        surface: darkCard,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // ... (el resto de tu configuración de navigationBar y floatingActionButton se mantiene igual)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: textSecondary, fontSize: 12);
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
