import 'package:intl/intl.dart';
import 'food_item.dart';

class DayEntry {
  final DateTime date;
  List<FoodItem> foods;
  bool hadReaction;
  String? reactionNotes;
  String? mood;
  int? energyLevel;
  List<String> tags;

  DayEntry({
    required this.date,
    List<FoodItem>? foods,
    this.hadReaction = false,
    this.reactionNotes,
    this.mood,
    this.energyLevel,
    List<String>? tags,
  }) : foods = foods ?? [],
       tags = tags ?? [];

  String get dateKey => DateFormat('yyyy-MM-dd').format(date);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'foods': foods.map((f) => f.toJson()).toList(),
    'hadReaction': hadReaction,
    'reactionNotes': reactionNotes,
    'mood': mood,
    'energyLevel': energyLevel,
    'tags': tags,
  };

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      date: DateTime.parse(json['date']),
      foods: (json['foods'] as List)
          .map((f) => FoodItem.fromJson(f as Map<String, dynamic>))
          .toList(),
      hadReaction: json['hadReaction'] ?? false,
      reactionNotes: json['reactionNotes'],
      mood: json['mood'],
      energyLevel: json['energyLevel'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}
