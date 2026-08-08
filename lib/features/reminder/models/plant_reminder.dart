enum ReminderType {
  watering,
  fertilizing,
  sunlight,
  treatment,
  custom,
}

class PlantReminder {
  final String id;
  final String plantName;
  final String title;
  final String description;
  final ReminderType type;
  final DateTime scheduledAt;
  final bool isCompleted;

  const PlantReminder({
    required this.id,
    required this.plantName,
    required this.title,
    required this.description,
    required this.type,
    required this.scheduledAt,
    this.isCompleted = false,
  });

  PlantReminder copyWith({
    String? id,
    String? plantName,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledAt,
    bool? isCompleted,
  }) {
    return PlantReminder(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

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
}