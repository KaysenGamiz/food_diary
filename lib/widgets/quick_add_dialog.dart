import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickAddDialog extends StatefulWidget {
  final Function(String type, {String? name, TimeOfDay? time}) onAdd;

  const QuickAddDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  String _currentView = 'menu';
  final _foodController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: _currentView == 'menu' ? _buildMenu() : _buildFoodForm(),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Atajos de hoy",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),

        // --- PRIMERA FILA: COMIDA, MOOD, ENERGÍA ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickIcon(Icons.restaurant, "Comida", AppTheme.primary, () {
              setState(() => _currentView = 'food');
            }),
            _buildQuickIcon(Icons.mood, "Mood", Colors.amber, () {
              widget.onAdd('mood');
              Navigator.pop(context);
            }),
            _buildQuickIcon(Icons.bolt, "Energía", Colors.yellow, () {
              widget.onAdd('energy');
              Navigator.pop(context);
            }),
          ],
        ),
        const SizedBox(height: 20),

        // --- SEGUNDA FILA: TAGS Y SALUD ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickIcon(
              Icons.local_offer_outlined,
              "Tags",
              AppTheme.tagActivity,
              () {
                widget.onAdd('tags');
                Navigator.pop(context);
              },
            ),
            _buildQuickIcon(
              Icons.healing_outlined,
              "Salud",
              AppTheme.danger,
              () {
                widget.onAdd('health');
                Navigator.pop(context);
              },
            ),
            // Espaciador para mantener el tamaño de los iconos si quieres añadir un 6to después
            const Opacity(
              opacity: 0,
              child: Column(children: [CircleAvatar(), Text("")]),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(color: AppTheme.darkDivider),
        const SizedBox(height: 12),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CERRAR",
            style: TextStyle(color: AppTheme.textTertiary, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- ENCABEZADO CON ICONO CENTRADO ---
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                ), // Estilo más moderno
                onPressed: () => setState(() => _currentView = 'menu'),
              ),
            ),
            // El icono de Comida centrado como en tu dibujo
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Comida",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // --- CONTENEDOR DEL FORMULARIO (Borde tipo tarjeta) ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.darkDivider, width: 1),
          ),
          child: Column(
            children: [
              TextField(
                controller: _foodController,
                textAlign: TextAlign.center, // Centrado para seguir la estética
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '¿Qué comiste?',
                  hintStyle: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 16,
                  ),
                  border: InputBorder
                      .none, // Quitamos la línea de abajo para un look limpio
                ),
                autofocus: true,
              ),
              const Divider(color: AppTheme.darkDivider, height: 24),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hora: ${_selectedTime.format(context)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- BOTÓN DE ACCIÓN ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_foodController.text.isNotEmpty) {
                widget.onAdd(
                  'food_save',
                  name: _foodController.text,
                  time: _selectedTime,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              "AGREGAR",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIcon(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80, // Ancho fijo para alinear las columnas
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
