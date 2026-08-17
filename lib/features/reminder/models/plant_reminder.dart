enum ReminderType {
  watering,
  fertilizing,
  sunlight,
  treatment,
  custom,
}

enum ReminderMode {
  notification,
  alarm,
}

class PlantReminder {
  final String id;

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  final String plantName;
  final String title;
  final String description;
  final ReminderType type;

  // ============================================================
  // SCHEDULE
  // ============================================================

  final DateTime scheduledAt;

  // ============================================================
  // STATUS
  // ============================================================

  final bool isCompleted;
  final bool isEnabled;

  // ============================================================
  // MODE
  // ============================================================

  final ReminderMode mode;

  // ============================================================
  // SOUND
  // ============================================================

  final String? soundPath;
  final String? soundName;

  // ============================================================
  // UNIQUE ID
  // ============================================================

  final int notificationId;

  const PlantReminder({
    required this.id,
    required this.plantName,
    required this.title,
    required this.description,
    required this.type,
    required this.scheduledAt,
    this.isCompleted = false,
    this.isEnabled = true,
    this.mode = ReminderMode.notification,
    this.soundPath,
    this.soundName,
    required this.notificationId,
  });

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isAlarm => mode == ReminderMode.alarm;

  bool get isNotification =>
      mode == ReminderMode.notification;

  bool get hasCustomSound =>
      soundPath != null &&
      soundPath!.trim().isNotEmpty;

  String get typeLabel {
    switch (type) {
      case ReminderType.watering:
        return 'Watering';
      case ReminderType.fertilizing:
        return 'Fertilizing';
      case ReminderType.sunlight:
        return 'Sunlight';
      case ReminderType.treatment:
        return 'Treatment';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String get modeLabel {
    switch (mode) {
      case ReminderMode.notification:
        return 'Notification';
      case ReminderMode.alarm:
        return 'Alarm';
    }
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PlantReminder copyWith({
    String? id,
    String? plantName,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledAt,
    bool? isCompleted,
    bool? isEnabled,
    ReminderMode? mode,
    String? soundPath,
    String? soundName,
    int? notificationId,
    bool clearSound = false,
  }) {
    return PlantReminder(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isEnabled: isEnabled ?? this.isEnabled,
      mode: mode ?? this.mode,
      soundPath: clearSound
          ? null
          : soundPath ?? this.soundPath,
      soundName: clearSound
          ? null
          : soundName ?? this.soundName,
      notificationId:
          notificationId ?? this.notificationId,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantName': plantName,
      'title': title,
      'description': description,
      'type': type.name,
      'scheduledAt': scheduledAt.toIso8601String(),
      'isCompleted': isCompleted,
      'isEnabled': isEnabled,
      'mode': mode.name,
      'soundPath': soundPath,
      'soundName': soundName,
      'notificationId': notificationId,
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory PlantReminder.fromJson(
    Map<String, dynamic> json,
  ) {
    ReminderType parsedType =
        ReminderType.custom;

    final typeValue =
        json['type']?.toString();

    for (final type in ReminderType.values) {
      if (type.name == typeValue) {
        parsedType = type;
        break;
      }
    }

    ReminderMode parsedMode =
        ReminderMode.notification;

    final modeValue =
        json['mode']?.toString();

    for (final mode in ReminderMode.values) {
      if (mode.name == modeValue) {
        parsedMode = mode;
        break;
      }
    }

    final parsedDate =
        DateTime.tryParse(
      json['scheduledAt']?.toString() ?? '',
    );

    int notificationId = 0;

    final rawId =
        json['notificationId'];

    if (rawId is int) {
      notificationId = rawId;
    } else if (rawId is num) {
      notificationId = rawId.toInt();
    } else {
      notificationId =
          int.tryParse(
                rawId?.toString() ?? '',
              ) ??
              0;
    }

    return PlantReminder(
      id: json['id']?.toString() ?? '',
      plantName:
          json['plantName']?.toString() ??
              'Unknown Plant',
      title:
          json['title']?.toString() ??
              'Plant Reminder',
      description:
          json['description']?.toString() ?? '',
      type: parsedType,
      scheduledAt:
          parsedDate ?? DateTime.now(),
      isCompleted:
          json['isCompleted'] == true,
      isEnabled:
          json['isEnabled'] != false,
      mode: parsedMode,
      soundPath:
          json['soundPath']?.toString(),
      soundName:
          json['soundName']?.toString(),
      notificationId:
          notificationId,
    );
  }
}