import 'package:intl/intl.dart';
import 'food_item.dart';

class DayEntry {
  final DateTime date;
  List<FoodItem> foods;
  bool hadReaction;
  String? reactionNotes;

  DayEntry({
    required this.date,
    this.foods = const [],
    this.hadReaction = false,
    this.reactionNotes,
  });

  String get dateKey => DateFormat('yyyy-MM-dd').format(date);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'foods': foods.map((f) => f.toJson()).toList(),
    'hadReaction': hadReaction,
    'reactionNotes': reactionNotes,
  };

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      date: DateTime.parse(json['date']),
      foods: (json['foods'] as List).map((f) => FoodItem.fromJson(f)).toList(),
      hadReaction: json['hadReaction'] ?? false,
      reactionNotes: json['reactionNotes'],
    );
  }
}
