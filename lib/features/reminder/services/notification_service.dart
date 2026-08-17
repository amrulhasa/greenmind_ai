import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/plant_reminder.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  // ============================================================
  // LOCAL NOTIFICATIONS
  // ============================================================

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============================================================
  // NOTIFICATION CHANNEL
  // ============================================================

  static const String _channelId = 'plant_reminders';

  static const String _channelName = 'Plant Reminders';

  static const String _channelDescription =
      'Notifications for plant care reminders.';

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // ----------------------------------------------------------
    // TIMEZONE DATABASE
    // ----------------------------------------------------------

    tz.initializeTimeZones();

    // ----------------------------------------------------------
    // DETECT DEVICE TIMEZONE
    // ----------------------------------------------------------

    try {
      final timezoneInfo =
          await FlutterTimezone.getLocalTimezone();

      final timezoneName = timezoneInfo.identifier;

      tz.setLocalLocation(
        tz.getLocation(timezoneName),
      );

      debugPrint(
        'Notification timezone: $timezoneName',
      );
    } catch (e) {
      debugPrint(
        'Unable to detect timezone: $e',
      );
    }

    // ----------------------------------------------------------
    // ALARM INITIALIZATION
    // ----------------------------------------------------------

    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS)) {
      await Alarm.init();
    }

    // ----------------------------------------------------------
    // LOCAL NOTIFICATION INITIALIZATION
    // ----------------------------------------------------------

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    // ----------------------------------------------------------
    // ANDROID PERMISSIONS
    // ----------------------------------------------------------

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      // Notification permission
      await androidPlugin
          ?.requestNotificationsPermission();

      // Exact alarm permission
      await androidPlugin
          ?.requestExactAlarmsPermission();
    }

    // ----------------------------------------------------------
    // ANDROID NOTIFICATION CHANNEL
    // ----------------------------------------------------------

    if (!kIsWeb && Platform.isAndroid) {
      const channel =
          AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin
          ?.createNotificationChannel(channel);
    }

    _initialized = true;

    debugPrint(
      'NotificationService initialized.',
    );
  }

  // ============================================================
  // SCHEDULE REMINDER
  // ============================================================

  Future<void> scheduleReminder(
    PlantReminder reminder,
  ) async {
    await initialize();

    // ----------------------------------------------------------
    // DISABLED
    // ----------------------------------------------------------

    if (!reminder.isEnabled) {
      debugPrint(
        'Reminder disabled: ${reminder.id}',
      );
      return;
    }

    // ----------------------------------------------------------
    // COMPLETED
    // ----------------------------------------------------------

    if (reminder.isCompleted) {
      debugPrint(
        'Reminder completed: ${reminder.id}',
      );
      return;
    }

    // ----------------------------------------------------------
    // PAST
    // ----------------------------------------------------------

    if (!reminder.scheduledAt.isAfter(
      DateTime.now(),
    )) {
      debugPrint(
        'Reminder is in the past: ${reminder.id}',
      );
      return;
    }

    debugPrint(
      'Scheduling ${reminder.modeLabel}: '
      '${reminder.title}',
    );

    // ----------------------------------------------------------
    // CANCEL OLD SCHEDULE
    // ----------------------------------------------------------

    await _cancelExisting(
      reminder.notificationId,
    );

    // ----------------------------------------------------------
    // ALARM
    // ----------------------------------------------------------

    if (reminder.isAlarm) {
      if (kIsWeb) {
        debugPrint(
          'Alarm mode is not supported on Web.',
        );
        return;
      }

      await _scheduleAlarm(
        reminder,
      );

      return;
    }

    // ----------------------------------------------------------
    // NORMAL NOTIFICATION
    // ----------------------------------------------------------

    await _scheduleNotification(
      reminder,
    );
  }

  // ============================================================
  // NORMAL NOTIFICATION
  // ============================================================

  Future<void> _scheduleNotification(
    PlantReminder reminder,
  ) async {
    final scheduledDate =
        tz.TZDateTime.from(
      reminder.scheduledAt,
      tz.local,
    );

    const androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription:
          _channelDescription,

      // High priority notification
      importance: Importance.max,
      priority: Priority.max,

      // Sound
      playSound: true,

      // Vibration
      enableVibration: true,

      // Badge
      number: 1,

      // Alert every time
      onlyAlertOnce: false,

      // Show on lock screen
      visibility:
          NotificationVisibility.public,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id: reminder.notificationId,

      title: reminder.title,

      body: _notificationBody(
        reminder,
      ),

      scheduledDate: scheduledDate,

      notificationDetails:
          notificationDetails,

      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,

      payload: reminder.id,
    );

    debugPrint(
      'Notification scheduled. '
      'ID=${reminder.notificationId}',
    );
  }

  // ============================================================
  // ALARM
  // ============================================================

  Future<void> _scheduleAlarm(
    PlantReminder reminder,
  ) async {
    // ----------------------------------------------------------
    // CUSTOM AUDIO
    // ----------------------------------------------------------

    String? audioPath;

    if (reminder.hasCustomSound) {
      final path =
          reminder.soundPath!.trim();

      final audioFile = File(path);

      // --------------------------------------------------------
      // FILE EXISTS
      // --------------------------------------------------------

      if (!await audioFile.exists()) {
        throw Exception(
          'Custom alarm sound file does not exist.',
        );
      }

      // --------------------------------------------------------
      // FILE SIZE
      // --------------------------------------------------------

      final size =
          await audioFile.length();

      if (size <= 0) {
        throw Exception(
          'Custom alarm sound file is empty.',
        );
      }

      audioPath = path;

      debugPrint(
        'Using custom alarm sound: $audioPath',
      );
    } else {
      // --------------------------------------------------------
      // DEFAULT DEVICE ALARM SOUND
      // --------------------------------------------------------

      audioPath = null;

      debugPrint(
        'Using default device alarm sound.',
      );
    }

    // ==========================================================
    // VOLUME SETTINGS
    // ==========================================================
    //
    // IMPORTANT:
    //
    // Duration.zero causes this assertion:
    //
    // fadeDuration == null ||
    // fadeDuration > Duration.zero
    //
    // Therefore we use a positive duration.
    //
    // ==========================================================

    final volumeSettings =
        VolumeSettings.fade(
      volume: 1.0,

      // MUST be greater than Duration.zero.
      fadeDuration:
          const Duration(seconds: 1),

      volumeEnforced: false,
    );

    // ==========================================================
    // ALARM SETTINGS
    // ==========================================================

    final alarmSettings =
        AlarmSettings(
      // --------------------------------------------------------
      // UNIQUE ALARM ID
      // --------------------------------------------------------

      id: reminder.notificationId,

      // --------------------------------------------------------
      // DATE / TIME
      // --------------------------------------------------------

      dateTime: reminder.scheduledAt,

      // --------------------------------------------------------
      // AUDIO
      // --------------------------------------------------------
      //
      // null = device default alarm sound
      // path = selected custom music
      //
      // --------------------------------------------------------

      assetAudioPath: audioPath,

      // --------------------------------------------------------
      // LOOP
      // --------------------------------------------------------

      loopAudio: true,

      // --------------------------------------------------------
      // VIBRATION
      // --------------------------------------------------------

      vibrate: true,

      // --------------------------------------------------------
      // FULL SCREEN
      // --------------------------------------------------------

      androidFullScreenIntent: true,

      // --------------------------------------------------------
      // KEEP RUNNING AFTER APP TERMINATION
      // --------------------------------------------------------

      androidStopAlarmOnTermination: false,

      // --------------------------------------------------------
      // VOLUME
      // --------------------------------------------------------

      volumeSettings: volumeSettings,

      // --------------------------------------------------------
      // ALARM NOTIFICATION
      // --------------------------------------------------------

      notificationSettings:
          NotificationSettings(
        title: reminder.title,

        body: _notificationBody(
          reminder,
        ),

        stopButton: 'Stop Alarm',
      ),

      // --------------------------------------------------------
      // PAYLOAD
      // --------------------------------------------------------

      payload: reminder.id,
    );

    // ==========================================================
    // SET ALARM
    // ==========================================================

    await Alarm.set(
      alarmSettings: alarmSettings,
    );

    debugPrint(
      'Alarm scheduled. '
      'ID=${reminder.notificationId}',
    );
  }

  // ============================================================
  // NOTIFICATION BODY
  // ============================================================

  String _notificationBody(
    PlantReminder reminder,
  ) {
    final description =
        reminder.description.trim();

    if (description.isEmpty) {
      return reminder.plantName;
    }

    return '${reminder.plantName} • '
        '$description';
  }

  // ============================================================
  // CANCEL EXISTING
  // ============================================================

  Future<void> _cancelExisting(
    int id,
  ) async {
    // ----------------------------------------------------------
    // CANCEL NORMAL NOTIFICATION
    // ----------------------------------------------------------

    try {
      await _notifications.cancel(
        id: id,
      );
    } catch (e) {
      debugPrint(
        'Unable to cancel notification $id: $e',
      );
    }

    // ----------------------------------------------------------
    // CANCEL ALARM
    // ----------------------------------------------------------

    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS)) {
      try {
        await Alarm.stop(id);
      } catch (e) {
        debugPrint(
          'Unable to stop alarm $id: $e',
        );
      }
    }
  }

  // ============================================================
  // CANCEL REMINDER
  // ============================================================

  Future<void> cancelReminder(
    PlantReminder reminder,
  ) async {
    await initialize();

    await _cancelExisting(
      reminder.notificationId,
    );

    debugPrint(
      'Reminder cancelled: ${reminder.id}',
    );
  }

  // ============================================================
  // CANCEL BY NOTIFICATION ID
  // ============================================================

  Future<void> cancelById(
    int notificationId,
  ) async {
    await initialize();

    await _cancelExisting(
      notificationId,
    );
  }

  // ============================================================
  // RESCHEDULE ALL REMINDERS
  // ============================================================

  Future<void> rescheduleReminders(
    List<PlantReminder> reminders,
  ) async {
    await initialize();

    for (final reminder in reminders) {
      // --------------------------------------------------------
      // DISABLED
      // --------------------------------------------------------

      if (!reminder.isEnabled) {
        continue;
      }

      // --------------------------------------------------------
      // COMPLETED
      // --------------------------------------------------------

      if (reminder.isCompleted) {
        continue;
      }

      // --------------------------------------------------------
      // PAST
      // --------------------------------------------------------

      if (!reminder.scheduledAt.isAfter(
        DateTime.now(),
      )) {
        continue;
      }

      // --------------------------------------------------------
      // INVALID ID
      // --------------------------------------------------------

      if (reminder.notificationId <= 0) {
        continue;
      }

      try {
        await scheduleReminder(
          reminder,
        );
      } catch (e) {
        debugPrint(
          'Unable to reschedule '
          '${reminder.id}: $e',
        );
      }
    }
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAll() async {
    await initialize();

    // ----------------------------------------------------------
    // CANCEL ALL NOTIFICATIONS
    // ----------------------------------------------------------

    await _notifications.cancelAll();

    // ----------------------------------------------------------
    // CANCEL ALL ALARMS
    // ----------------------------------------------------------

    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS)) {
      try {
        final alarms =
            await Alarm.getAlarms();

        for (final alarm in alarms) {
          try {
            await Alarm.stop(
              alarm.id,
            );
          } catch (e) {
            debugPrint(
              'Unable to stop alarm '
              '${alarm.id}: $e',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'Unable to get alarms: $e',
        );
      }
    }
  }
}