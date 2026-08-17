import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/plant_reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_storage_service.dart';

// ============================================================
// STORAGE PROVIDER
// ============================================================

final reminderStorageServiceProvider =
    Provider<ReminderStorageService>(
  (ref) => ReminderStorageService(),
);

// ============================================================
// NOTIFICATION SERVICE PROVIDER
// ============================================================

final notificationServiceProvider =
    Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

// ============================================================
// REMINDER PROVIDER
// ============================================================

final reminderProvider =
    NotifierProvider<
        ReminderNotifier,
        ReminderState>(
  ReminderNotifier.new,
);

// ============================================================
// NOTIFIER
// ============================================================

class ReminderNotifier
    extends Notifier<ReminderState> {
  final Uuid _uuid =
      const Uuid();

  ReminderStorageService
      get _storageService {
    return ref.read(
      reminderStorageServiceProvider,
    );
  }

  NotificationService
      get _notificationService {
    return ref.read(
      notificationServiceProvider,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  ReminderState build() {
    Future.microtask(
      _initialize,
    );

    return const ReminderState(
      isLoading: true,
    );
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    try {
      await _notificationService
          .initialize();

      await _loadReminders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to initialize reminders: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadReminders() async {
    try {
      final reminders =
          await _storageService
              .loadReminders();

      state = state.copyWith(
        reminders:
            reminders,
        isLoading:
            false,
        clearError:
            true,
      );

      // Restore future notifications.
      await _notificationService
          .rescheduleReminders(
        reminders,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load reminders: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // RELOAD
  // ============================================================

  Future<void>
      reloadReminders() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    await _loadReminders();
  }

  // ============================================================
  // ADD REMINDER
  // ============================================================

  Future<void> addReminder({
    required String plantName,
    required String title,
    required String description,
    required ReminderType type,
    required DateTime scheduledAt,
    ReminderMode mode =
        ReminderMode.notification,
    String? soundPath,
    String? soundName,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      final cleanPlantName =
          plantName.trim();

      final cleanTitle =
          title.trim();

      final cleanDescription =
          description.trim();

      if (cleanPlantName.isEmpty) {
        throw Exception(
          'Plant name is required.',
        );
      }

      if (cleanTitle.isEmpty) {
        throw Exception(
          'Reminder title is required.',
        );
      }

      if (!scheduledAt.isAfter(
        DateTime.now(),
      )) {
        throw Exception(
          'Reminder time must be in the future.',
        );
      }

      // ----------------------------------------------------------
      // ALARM SOUND
      // ----------------------------------------------------------

      final finalSoundPath =
          mode == ReminderMode.alarm
              ? _cleanNullable(
                  soundPath,
                )
              : null;

      final finalSoundName =
          mode == ReminderMode.alarm
              ? _cleanNullable(
                  soundName,
                )
              : null;

      // ----------------------------------------------------------
      // UNIQUE NOTIFICATION ID
      // ----------------------------------------------------------

      final notificationId =
          _generateNotificationId();

      // ----------------------------------------------------------
      // CREATE MODEL
      // ----------------------------------------------------------

      final reminder =
          PlantReminder(
        id:
            _uuid.v4(),

        plantName:
            cleanPlantName,

        title:
            cleanTitle,

        description:
            cleanDescription,

        type:
            type,

        scheduledAt:
            scheduledAt,

        isCompleted:
            false,

        isEnabled:
            true,

        mode:
            mode,

        soundPath:
            finalSoundPath,

        soundName:
            finalSoundName,

        notificationId:
            notificationId,
      );

      // ----------------------------------------------------------
      // SCHEDULE FIRST
      // ----------------------------------------------------------

      await _notificationService
          .scheduleReminder(
        reminder,
      );

      // ----------------------------------------------------------
      // SAVE AFTER SCHEDULE SUCCESS
      // ----------------------------------------------------------

      final updatedReminders =
          <PlantReminder>[
        ...state.reminders,
        reminder,
      ];

      try {
        await _storageService
            .saveReminders(
          updatedReminders,
        );
      } catch (saveError) {
        // Roll back scheduled notification.
        await _notificationService
            .cancelReminder(
          reminder,
        );

        throw Exception(
          'Reminder scheduled but could not be saved: '
          '$saveError',
        );
      }

      // ----------------------------------------------------------
      // UPDATE STATE
      // ----------------------------------------------------------

      state = state.copyWith(
        reminders:
            updatedReminders,
        isLoading:
            false,
        clearError:
            true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading:
            false,
        errorMessage:
            _cleanError(e),
      );
    }
  }

  // ============================================================
  // TOGGLE COMPLETED
  // ============================================================

  Future<void> toggleCompleted(
    String reminderId,
  ) async {
    try {
      final reminder =
          _findReminder(
        reminderId,
      );

      if (reminder == null) {
        return;
      }

      final updatedReminder =
          reminder.copyWith(
        isCompleted:
            !reminder.isCompleted,
      );

      final updatedReminders =
          state.reminders
              .map(
        (item) {
          if (item.id ==
              reminderId) {
            return updatedReminder;
          }

          return item;
        },
      ).toList();

      // ----------------------------------------------------------
      // COMPLETED = CANCEL
      // ----------------------------------------------------------

      if (updatedReminder
          .isCompleted) {
        await _notificationService
            .cancelReminder(
          updatedReminder,
        );
      }

      // ----------------------------------------------------------
      // PENDING AGAIN = RESCHEDULE
      // ----------------------------------------------------------

      else if (updatedReminder
              .isEnabled &&
          updatedReminder
              .scheduledAt
              .isAfter(
            DateTime.now(),
          )) {
        await _notificationService
            .scheduleReminder(
          updatedReminder,
        );
      }

      await _storageService
          .saveReminders(
        updatedReminders,
      );

      state = state.copyWith(
        reminders:
            updatedReminders,
        clearError:
            true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to update reminder: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<void> toggleEnabled(
    String reminderId,
  ) async {
    try {
      final reminder =
          _findReminder(
        reminderId,
      );

      if (reminder == null) {
        return;
      }

      final updatedReminder =
          reminder.copyWith(
        isEnabled:
            !reminder.isEnabled,
      );

      final updatedReminders =
          state.reminders
              .map(
        (item) {
          if (item.id ==
              reminderId) {
            return updatedReminder;
          }

          return item;
        },
      ).toList();

      // ----------------------------------------------------------
      // DISABLED
      // ----------------------------------------------------------

      if (!updatedReminder
          .isEnabled) {
        await _notificationService
            .cancelReminder(
          updatedReminder,
        );
      }

      // ----------------------------------------------------------
      // ENABLED
      // ----------------------------------------------------------

      else if (!updatedReminder
              .isCompleted &&
          updatedReminder
              .scheduledAt
              .isAfter(
            DateTime.now(),
          )) {
        await _notificationService
            .scheduleReminder(
          updatedReminder,
        );
      }

      await _storageService
          .saveReminders(
        updatedReminders,
      );

      state = state.copyWith(
        reminders:
            updatedReminders,
        clearError:
            true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to update reminder: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteReminder(
    String reminderId,
  ) async {
    try {
      final reminder =
          _findReminder(
        reminderId,
      );

      if (reminder != null) {
        await _notificationService
            .cancelReminder(
          reminder,
        );
      }

      final updatedReminders =
          state.reminders
              .where(
        (item) =>
            item.id !=
            reminderId,
      ).toList();

      await _storageService
          .saveReminders(
        updatedReminders,
      );

      state = state.copyWith(
        reminders:
            updatedReminders,
        clearError:
            true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to delete reminder: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void>
      clearAllReminders() async {
    try {
      await _notificationService
          .cancelAll();

      await _storageService
          .clearReminders();

      state = state.copyWith(
        reminders:
            const [],
        isLoading:
            false,
        clearError:
            true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Unable to clear reminders: '
            '${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // FIND
  // ============================================================

  PlantReminder?
      _findReminder(
    String reminderId,
  ) {
    for (final reminder
        in state.reminders) {
      if (reminder.id ==
          reminderId) {
        return reminder;
      }
    }

    return null;
  }

  // ============================================================
  // GENERATE NOTIFICATION ID
  // ============================================================

  int _generateNotificationId() {
    final value =
        DateTime.now()
            .microsecondsSinceEpoch
            .remainder(
              2147483647,
            );

    return value <= 0
        ? 1
        : value;
  }

  // ============================================================
  // CLEAN NULLABLE STRING
  // ============================================================

  String? _cleanNullable(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final clean =
        value.trim();

    return clean.isEmpty
        ? null
        : clean;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    final text =
        error.toString();

    if (text.startsWith(
      'Exception: ',
    )) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }
}

// ============================================================
// STATE
// ============================================================

class ReminderState {
  final List<PlantReminder>
      reminders;

  final bool isLoading;

  final String? errorMessage;

  const ReminderState({
    this.reminders =
        const [],

    this.isLoading =
        false,

    this.errorMessage,
  });

  ReminderState copyWith({
    List<PlantReminder>?
        reminders,

    bool? isLoading,

    String? errorMessage,

    bool clearError =
        false,
  }) {
    return ReminderState(
      reminders:
          reminders ??
              this.reminders,

      isLoading:
          isLoading ??
              this.isLoading,

      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}