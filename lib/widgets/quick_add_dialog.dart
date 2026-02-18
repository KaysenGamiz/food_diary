import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/quick_add_model.dart';

class QuickAddDialog extends StatefulWidget {
  final String? initialMood;
  final int? initialEnergy;
  final List<String> initialTags;

  final Function(
    QuickAddType type, {
    int? energy,
    bool? health,
    String? mood,
    String? name,
    List<String>? tags,
    TimeOfDay? time,
  })
  onAdd;

  const QuickAddDialog({
    super.key,
    this.initialMood,
    this.initialEnergy,
    required this.initialTags,
    required this.onAdd,
  });

  @override
  State<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<QuickAddDialog> {
  QuickAddType? _currentView;

  final _foodController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _selectedEnergy = 3.0;
  int _selectedMoodIndex = 2;
  List<String> _tempTags = [];
  bool _hadReaction = false;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Mal', 'emoji': '😡'},
    {'label': 'Triste', 'emoji': '😔'},
    {'label': 'Neutral', 'emoji': '😐'},
    {'label': 'Bien', 'emoji': '😊'},
    {'label': 'Excelente', 'emoji': '🤩'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedEnergy = (widget.initialEnergy ?? 3).toDouble();
    _tempTags = List.from(widget.initialTags);

    if (widget.initialMood != null) {
      _selectedMoodIndex = _moods.indexWhere(
        (m) => m['label'] == widget.initialMood,
      );
      if (_selectedMoodIndex == -1) _selectedMoodIndex = 2;
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_currentView == null) return _buildMenu();

    Widget inputs;
    switch (_currentView!) {
      case QuickAddType.food:
        inputs = _buildFoodInputs();
        break;
      case QuickAddType.mood:
        inputs = _buildMoodInputs();
        break;
      case QuickAddType.energy:
        inputs = _buildEnergyInputs();
        break;
      case QuickAddType.tags:
        inputs = _buildTagsInputs();
        break;
      case QuickAddType.health:
        inputs = _buildHealthInputs();
        break;
    }

    return _buildGenericForm(
      _currentView!.icon,
      _currentView!.title,
      _currentView!.color,
      inputs,
    );
  }

  // --- ESTRUCTURA GENÉRICA ---
  Widget _buildGenericForm(
    IconData icon,
    String title,
    Color color,
    Widget inputs,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _currentView = null),
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.darkDivider),
          ),
          child: inputs,
        ),
        const SizedBox(height: 24),
        _buildSaveButton(),
      ],
    );
  }

  // --- INPUTS ESPECÍFICOS ---
  Widget _buildFoodInputs() {
    return Column(
      children: [
        TextField(
          controller: _foodController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
          decoration: const InputDecoration(
            hintText: '¿Qué comiste?',
            border: InputBorder.none,
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
              const Icon(Icons.access_time, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Hora: ${_selectedTime.format(context)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_moods.length, (index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedMoodIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedMoodIndex == index
                  ? Colors.white10
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedMoodIndex == index
                    ? Colors.amber.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              _moods[index]['emoji'],
              style: const TextStyle(fontSize: 32),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEnergyInputs() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isActive = _selectedEnergy >= level;
            return GestureDetector(
              onTap: () => setState(() => _selectedEnergy = level.toDouble()),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isActive ? 1.2 : 1.0,
                child: Icon(
                  Icons.bolt,
                  size: 40,
                  color: isActive
                      ? Colors.yellow[700]
                      : AppTheme.textTertiary.withOpacity(0.2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          _selectedEnergy <= 2
              ? "Baja"
              : (_selectedEnergy >= 4 ? "Alta" : "Media"),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsInputs() {
    final availableTags = [
      'Café',
      'Alcohol',
      'Gimnasio',
      'Estrés',
      'Poco Sueño',
      'Ayuno',
      'Viaje',
      'Medicamento',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: availableTags.map((tag) {
        final isSelected = _tempTags.contains(tag);
        final Color tagColor = AppTheme.getTagColor(tag);

        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (bool value) {
            setState(() {
              value ? _tempTags.add(tag) : _tempTags.remove(tag);
            });
          },
          selectedColor: tagColor.withOpacity(0.2),
          checkmarkColor: tagColor,
          labelStyle: TextStyle(
            color: isSelected ? tagColor : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? tagColor : AppTheme.darkDivider,
              width: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthInputs() {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: const Text("¿Hubo malestar?", style: TextStyle(fontSize: 16)),
      subtitle: const Text(
        "Marca si sentiste síntomas inusuales",
        style: TextStyle(fontSize: 11),
      ),
      value: _hadReaction,
      activeColor: AppTheme.danger,
      onChanged: (val) => setState(() => _hadReaction = val),
    );
  }

  // --- BOTÓN DE GUARDADO OPTIMIZADO ---
  Widget _buildSaveButton() {
    if (_currentView == null) return const SizedBox.shrink();

    final type = _currentView!;
    final buttonColor = type.color;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () {
          switch (type) {
            case QuickAddType.food:
              if (_foodController.text.isNotEmpty) {
                widget.onAdd(
                  type,
                  name: _foodController.text,
                  time: _selectedTime,
                );
              }
              break;
            case QuickAddType.mood:
              widget.onAdd(type, mood: _moods[_selectedMoodIndex]['label']);
              break;
            case QuickAddType.energy:
              widget.onAdd(type, energy: _selectedEnergy.toInt());
              break;
            case QuickAddType.tags:
              widget.onAdd(type, tags: _tempTags);
              break;
            case QuickAddType.health:
              widget.onAdd(type, health: _hadReaction);
              break;
          }

          Navigator.pop(context);
        },
        child: Text(
          "AGREGAR ${type.title.toUpperCase()}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  // --- MENÚ PRINCIPAL ---
  Widget _buildMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Atajos de hoy",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickIcon(
              Icons.restaurant,
              "Comida",
              AppTheme.primary,
              () => setState(() => _currentView = QuickAddType.food),
            ),
            _buildQuickIcon(
              Icons.mood,
              "Mood",
              Colors.amber,
              () => setState(() => _currentView = QuickAddType.mood),
            ),
            _buildQuickIcon(
              Icons.bolt,
              "Energía",
              Colors.yellow,
              () => setState(() => _currentView = QuickAddType.energy),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickIcon(
              Icons.local_offer_outlined,
              "Tags",
              AppTheme.tagActivity,
              () => setState(() => _currentView = QuickAddType.tags),
            ),
            _buildQuickIcon(
              Icons.healing_outlined,
              "Salud",
              AppTheme.danger,
              () => setState(() => _currentView = QuickAddType.health),
            ),
            const SizedBox(width: 80),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.darkDivider),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CERRAR",
            style: TextStyle(color: AppTheme.textTertiary),
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
      child: SizedBox(
        width: 80,
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
            ),
          ],
        ),
      ),
    );
  }
}
