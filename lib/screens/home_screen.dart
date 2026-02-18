import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models & Utils
import '../models/day_entry.dart';
import '../models/food_item.dart';
import '../models/quick_add_model.dart';
import '../models/nav_tab_model.dart';
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

  void _openQuickAdd() {
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DayEntry todayEntry =
        dayEntries[todayKey] ??
        DayEntry(date: DateTime.now(), foods: [], tags: []);

    showDialog(
      context: context,
      builder: (context) => QuickAddDialog(
        initialMood: todayEntry.mood,
        initialEnergy: todayEntry.energyLevel,
        initialTags: todayEntry.tags,
        onAdd: (type, {energy, health, mood, name, tags, time}) {
          setState(() {
            if (!dayEntries.containsKey(todayKey)) {
              dayEntries[todayKey] = todayEntry;
            }

            switch (type) {
              case QuickAddType.food:
                _addFoodToToday(name!, time!);
                break;
              case QuickAddType.mood:
                dayEntries[todayKey]!.mood = mood;
                break;
              case QuickAddType.energy:
                dayEntries[todayKey]!.energyLevel = energy;
                break;
              case QuickAddType.tags:
                dayEntries[todayKey]!.tags = tags ?? [];
                break;
              case QuickAddType.health:
                dayEntries[todayKey]!.hadReaction = health ?? false;
                break;
            }
          });
          _saveEntries();
        },
      ),
    );
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
    final Map<NavTab, Widget> screenMap = {
      NavTab.diary: DiaryScreen(
        dayEntries: dayEntries,
        onUpdateDay: _updateDay,
        onDeleteDay: _deleteDay,
      ),
      NavTab.log: FoodLogScreen(
        dayEntries: dayEntries,
        onSave: (updated) {
          setState(() => dayEntries = updated);
          _saveEntries();
        },
      ),
      NavTab.analysis: AnalysisScreen(dayEntries: dayEntries),
      NavTab.settings: const SettingsScreen(),
    };

    return Scaffold(
      body: screenMap[NavTab.values[_selectedIndex]] ?? screenMap[NavTab.diary],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (NavTab.values[index] == NavTab.add) {
            _openQuickAdd();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        destinations: NavTab.values.map((tab) {
          return NavigationDestination(
            icon: Icon(
              tab.icon,
              size: tab == NavTab.add ? 32 : null,
              color: tab == NavTab.add ? AppTheme.primary : null,
            ),
            selectedIcon: Icon(tab.selectedIcon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
