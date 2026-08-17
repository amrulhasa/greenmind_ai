import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_reminder.dart';
import 'reminder_provider.dart';

// ============================================================
// PROVIDER
// ============================================================

final notificationBadgeProvider =
    NotifierProvider<
        NotificationBadgeNotifier,
        int>(
  NotificationBadgeNotifier.new,
);

// ============================================================
// NOTIFIER
// ============================================================

class NotificationBadgeNotifier
    extends Notifier<int> {
  static const String
      _readKey =
      'greenmind_read_reminder_notifications';

  Timer? _timer;

  Set<String>
      _readReminderIds =
      <String>{};

  bool _initialized =
      false;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  int build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    Future.microtask(
      _initialize,
    );

    _timer = Timer.periodic(
      const Duration(
        seconds: 10,
      ),
      (_) {
        _updateCount();
      },
    );

    return 0;
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    await _loadReadReminderIds();

    _initialized =
        true;

    _updateCount();
  }

  // ============================================================
  // LOAD READ IDS
  // ============================================================

  Future<void>
      _loadReadReminderIds() async {
    try {
      final preferences =
          await SharedPreferences
              .getInstance();

      final savedIds =
          preferences
              .getStringList(
        _readKey,
      );

      if (savedIds == null ||
          savedIds.isEmpty) {
        _readReminderIds =
            <String>{};

        return;
      }

      _readReminderIds =
          savedIds.toSet();
    } catch (_) {
      _readReminderIds =
          <String>{};
    }
  }

  // ============================================================
  // SAVE READ IDS
  // ============================================================

  Future<void>
      _saveReadReminderIds() async {
    try {
      final preferences =
          await SharedPreferences
              .getInstance();

      await preferences
          .setStringList(
        _readKey,
        _readReminderIds
            .toList(),
      );
    } catch (_) {
      // Ignore storage failure.
    }
  }

  // ============================================================
  // UPDATE COUNT
  // ============================================================

  void _updateCount() {
    final reminderState =
        ref.read(
      reminderProvider,
    );

    if (reminderState
        .isLoading) {
      return;
    }

    final now =
        DateTime.now();

    int unreadCount = 0;

    for (final reminder
        in reminderState
            .reminders) {
      final isDue =
          !reminder
              .scheduledAt
              .isAfter(
        now,
      );

      final isUnread =
          !_readReminderIds
              .contains(
        reminder.id,
      );

      if (reminder.isEnabled &&
          !reminder.isCompleted &&
          isDue &&
          isUnread) {
        unreadCount++;
      }
    }

    state =
        unreadCount;

    _cleanupReadIds(
      reminderState.reminders,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  void refresh() {
    _updateCount();
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void>
      markAllAsRead() async {
    final reminderState =
        ref.read(
      reminderProvider,
    );

    final now =
        DateTime.now();

    for (final reminder
        in reminderState
            .reminders) {
      final isDue =
          !reminder
              .scheduledAt
              .isAfter(
        now,
      );

      if (reminder.isEnabled &&
          !reminder.isCompleted &&
          isDue) {
        _readReminderIds.add(
          reminder.id,
        );
      }
    }

    await _saveReadReminderIds();

    _updateCount();
  }

  // ============================================================
  // MARK ONE READ
  // ============================================================

  Future<void> markAsRead(
    String reminderId,
  ) async {
    _readReminderIds.add(
      reminderId,
    );

    await _saveReadReminderIds();

    _updateCount();
  }

  // ============================================================
  // MARK ONE UNREAD
  // ============================================================

  Future<void> markAsUnread(
    String reminderId,
  ) async {
    _readReminderIds.remove(
      reminderId,
    );

    await _saveReadReminderIds();

    _updateCount();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  Future<void> _cleanupReadIds(
    List<PlantReminder>
        reminders,
  ) async {
    final existingIds =
        reminders
            .map(
              (reminder) =>
                  reminder.id,
            )
            .toSet();

    final oldLength =
        _readReminderIds
            .length;

    _readReminderIds
        .removeWhere(
      (id) =>
          !existingIds
              .contains(id),
    );

    if (_readReminderIds
            .length !=
        oldLength) {
      await _saveReadReminderIds();
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clear() async {
    _readReminderIds.clear();

    try {
      final preferences =
          await SharedPreferences
              .getInstance();

      await preferences
          .remove(
        _readKey,
      );
    } catch (_) {}

    state = 0;
  }
}