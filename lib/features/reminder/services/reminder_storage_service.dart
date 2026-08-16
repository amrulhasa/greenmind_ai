import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_reminder.dart';

class ReminderStorageService {
  static const String _storageKey = 'plant_reminders';

  Future<List<PlantReminder>> loadReminders() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(storedData);

    return decodedData
        .map((item) => _fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveReminders(List<PlantReminder> reminders) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(reminders.map(_toJson).toList());

    await preferences.setString(_storageKey, encodedData);
  }

  Future<void> clearReminders() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  Map<String, dynamic> _toJson(PlantReminder reminder) {
    return {
      'id': reminder.id,
      'plantName': reminder.plantName,
      'title': reminder.title,
      'description': reminder.description,
      'type': reminder.type.name,
      'scheduledAt': reminder.scheduledAt.toIso8601String(),
      'isCompleted': reminder.isCompleted,
    };
  }

  PlantReminder _fromJson(Map<String, dynamic> json) {
    final reminderType = ReminderType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => ReminderType.custom,
    );

    return PlantReminder(
      id: json['id'] as String,
      plantName: json['plantName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: reminderType,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
