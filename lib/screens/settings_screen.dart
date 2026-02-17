import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AJUSTES')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Perfil y Datos"),
          _buildSettingsCard(
            icon: Icons.person_outline,
            title: "Información Personal",
            subtitle: "Nombre, peso, edad",
            onTap: () {},
          ),
          _buildSettingsCard(
            icon: Icons.file_download_outlined,
            title: "Exportar Datos (PDF/CSV)",
            subtitle: "Comparte tu diario con un médico",
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Personalización"),
          _buildSettingsCard(
            icon: Icons.palette_outlined,
            title: "Tema de la App",
            subtitle: "Personaliza colores de tags",
            onTap: () {},
          ),
          _buildSettingsCard(
            icon: Icons.notifications_none,
            title: "Recordatorios",
            subtitle: "Avisos para registrar comidas",
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Soporte"),
          _buildSettingsCard(
            icon: Icons.help_outline,
            title: "Ayuda y Guía",
            subtitle: "Cómo identificar intolerancias",
            onTap: () {},
          ),
          _buildSettingsCard(
            icon: Icons.info_outline,
            title: "Acerca de la App",
            subtitle: "Versión 1.0.0",
            onTap: () {},
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Diseñado para tu bienestar",
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textTertiary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: AppTheme.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}
