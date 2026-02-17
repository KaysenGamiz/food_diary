import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializamos el idioma español para fechas
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
      home: const HomeScreen(), // Llamamos al orquestador
    );
  }
}
