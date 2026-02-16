import 'package:flutter/material.dart';

class FoodItem {
  final String id;
  final String name;
  final TimeOfDay time;

  FoodItem({required this.id, required this.name, required this.time});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'time': '${time.hour}:${time.minute}',
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return FoodItem(
      id: json['id'],
      name: json['name'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}
