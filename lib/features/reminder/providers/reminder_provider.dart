import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/plant_reminder.dart';
import '../services/reminder_storage_service.dart';

final reminderStorageServiceProvider = Provider<ReminderStorageService>(
  (ref) => ReminderStorageService(),
);

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderState>(
  ReminderNotifier.new,
);

class ReminderNotifier extends Notifier<ReminderState> {
  final Uuid _uuid = const Uuid();

  ReminderStorageService get _storageService {
    return ref.read(reminderStorageServiceProvider);
  }

  @override
  ReminderState build() {
    Future.microtask(_loadReminders);

    return const ReminderState(isLoading: true);
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await _storageService.loadReminders();

      state = state.copyWith(
        reminders: reminders,
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load reminders.',
      );
    }
  }

  Future<void> addReminder({
    required String plantName,
    required String title,
    required String description,
    required ReminderType type,
    required DateTime scheduledAt,
  }) async {
    final reminder = PlantReminder(
      id: _uuid.v4(),
      plantName: plantName,
      title: title,
      description: description,
      type: type,
      scheduledAt: scheduledAt,
    );

    final updatedReminders = [...state.reminders, reminder];

    await _saveReminders(updatedReminders);
  }

  Future<void> toggleCompleted(String reminderId) async {
    final updatedReminders = state.reminders.map((reminder) {
      if (reminder.id == reminderId) {
        return reminder.copyWith(isCompleted: !reminder.isCompleted);
      }

      return reminder;
    }).toList();

    await _saveReminders(updatedReminders);
  }

  Future<void> deleteReminder(String reminderId) async {
    final updatedReminders = state.reminders
        .where((reminder) => reminder.id != reminderId)
        .toList();

    await _saveReminders(updatedReminders);
  }

  Future<void> clearAllReminders() async {
    await _storageService.clearReminders();

    state = state.copyWith(reminders: [], errorMessage: null);
  }

  Future<void> _saveReminders(List<PlantReminder> reminders) async {
    try {
      await _storageService.saveReminders(reminders);

      state = state.copyWith(reminders: reminders, errorMessage: null);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Unable to save reminder.');
    }
  }
}

class ReminderState {
  final List<PlantReminder> reminders;
  final bool isLoading;
  final String? errorMessage;

  const ReminderState({
    this.reminders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReminderState copyWith({
    List<PlantReminder>? reminders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
