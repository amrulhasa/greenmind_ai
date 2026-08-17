import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_reminder.dart';

class ReminderStorageService {
  static const String _storageKey =
      'plant_reminders';

  // ============================================================
  // LOAD
  // ============================================================

  Future<List<PlantReminder>> loadReminders() async {
    final preferences =
        await SharedPreferences.getInstance();

    final storedData =
        preferences.getString(_storageKey);

    if (storedData == null ||
        storedData.trim().isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(storedData);

      if (decoded is! List) {
        return [];
      }

      final reminders =
          <PlantReminder>[];

      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }

        try {
          final reminder =
              PlantReminder.fromJson(
            Map<String, dynamic>.from(item),
          );

          reminders.add(reminder);
        } catch (_) {
          // Ignore invalid reminder.
        }
      }

      return reminders;
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveReminders(
    List<PlantReminder> reminders,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final encoded =
        jsonEncode(
      reminders
          .map(
            (reminder) =>
                reminder.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearReminders() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      _storageKey,
    );
  }
}