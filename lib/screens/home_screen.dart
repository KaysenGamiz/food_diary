import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models & Utils
import '../models/day_entry.dart';
import '../models/food_item.dart';
import '../utils/storage_service.dart';
import '../theme/app_theme.dart';

// Screens
import 'diary_screen.dart';
import 'food_log_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

// Widgets
import '../widgets/quick_add_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, DayEntry> dayEntries = {};
  final StorageService storageService = StorageService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await storageService.loadEntries();
    setState(() {
      dayEntries = data;
    });
  }

  Future<void> _saveEntries() async {
    await storageService.saveEntries(dayEntries);
  }

  void _updateDay(DayEntry day) {
    setState(() {
      dayEntries[day.dateKey] = day;
    });
    _saveEntries();
  }

  void _deleteDay(String dateKey) {
    setState(() {
      dayEntries.remove(dateKey);
    });
    _saveEntries();
  }

  void _addFoodToToday(String name, TimeOfDay time) {
    final now = DateTime.now();
    final key = DateFormat('yyyy-MM-dd').format(now);

    setState(() {
      if (!dayEntries.containsKey(key)) {
        dayEntries[key] = DayEntry(date: now, foods: []);
      }

      final newFood = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        time: time,
      );

      dayEntries[key]!.foods.add(newFood);
    });

    _saveEntries();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name agregado a hoy'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DiaryScreen(
        dayEntries: dayEntries,
        onUpdateDay: _updateDay,
        onDeleteDay: _deleteDay,
      ),
      FoodLogScreen(
        dayEntries: dayEntries,
        onSave: (updated) {
          setState(() => dayEntries = updated);
          _saveEntries();
        },
      ),
      AnalysisScreen(dayEntries: dayEntries),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: _selectedIndex == 2
          ? screens[1]
          : (_selectedIndex > 2
                ? screens[_selectedIndex - 1]
                : screens[_selectedIndex]),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            showDialog(
              context: context,
              builder: (context) => QuickAddDialog(
                onAdd: (type, {name, time}) {
                  if (type == 'food_save') {
                    _addFoodToToday(name!, time!);
                  } else {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  }
                },
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Diario',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle, size: 32, color: AppTheme.primary),
            label: 'Añadir',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Análisis',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
