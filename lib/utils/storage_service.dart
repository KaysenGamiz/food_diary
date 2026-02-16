import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_entry.dart';

class StorageService {
  static const String _entriesKey = 'day_entries';

  // Quitamos 'static' para que funcione con la instancia creada en main.dart
  Future<Map<String, DayEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_entriesKey);

    if (entriesJson != null) {
      final Map<String, dynamic> decoded = json.decode(entriesJson);
      return decoded.map(
        (key, value) => MapEntry(key, DayEntry.fromJson(value)),
      );
    }
    return {};
  }

  // Quitamos 'static' aquí también
  Future<void> saveEntries(Map<String, DayEntry> dayEntries) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = dayEntries.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    final String encoded = json.encode(toSave);
    await prefs.setString(_entriesKey, encoded);
  }
}
