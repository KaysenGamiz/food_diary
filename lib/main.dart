import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Models
import 'models/food_item.dart';
import 'models/day_entry.dart';

// Screens
import 'screens/diary_screen.dart';
import 'screens/food_log_screen.dart';
import 'screens/analysis_screen.dart';

// Widgets
import 'widgets/quick_add_dialog.dart';

// Theme
import 'theme/app_theme.dart';

// Utils
import 'utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const FoodDiaryApp());
}

class FoodDiaryApp extends StatelessWidget {
  const FoodDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

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

  // Método unificado para guardar en disco
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

  // Obtiene o crea la entrada para una fecha específica
  DayEntry _getEntryForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (!dayEntries.containsKey(key)) {
      dayEntries[key] = DayEntry(date: date, foods: []);
    }
    return dayEntries[key]!;
  }

  void _addFoodToToday(String name, TimeOfDay time) {
    final now = DateTime.now();
    final todayEntry = _getEntryForDate(now);

    final newFood = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      time: time,
    );

    setState(() {
      todayEntry.foods.add(newFood);
      todayEntry.foods.sort((a, b) {
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
        return aMinutes.compareTo(bMinutes);
      });
    });

    _saveEntries();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('$name agregado a hoy'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      // Se eliminó 'const' porque pasamos una función
      builder: (context) => QuickAddDialog(
        onAdd: (name, time) {
          _addFoodToToday(name, time);
        },
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
        onSave: (updatedEntries) {
          setState(() {
            dayEntries = updatedEntries;
          });
          _saveEntries();
        },
      ),
      // Espacio reservado para el botón central de la NavigationBar
      const SizedBox.shrink(),
      AnalysisScreen(dayEntries: dayEntries),
    ];

    return Scaffold(
      // Lógica para manejar el índice del botón central "+"
      body: _selectedIndex == 2 ? screens[1] : screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex == 2 ? 1 : _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            _showQuickAddDialog();
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
            label: 'Food Log',
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
        ],
      ),
    );
  }
}
