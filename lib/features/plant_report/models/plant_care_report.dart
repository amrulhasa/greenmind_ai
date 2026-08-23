import 'dart:typed_data';

class PlantCareReport {
  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  final String plantName;
  final String scientificName;
  final String category;

  final double identificationConfidence;

  // ============================================================
  // HEALTH
  // ============================================================

  final String healthStatus;
  final int healthScore;

  // ============================================================
  // OVERVIEW
  // ============================================================

  final String overview;

  // ============================================================
  // CARE REQUIREMENTS
  // ============================================================

  final String sunlight;
  final String watering;
  final String soil;
  final String temperature;
  final String humidity;
  final String fertilizer;

  // ============================================================
  // HEALTH OBSERVATIONS
  // ============================================================

  final List<String> symptoms;

  // ============================================================
  // AI RECOMMENDATIONS
  // ============================================================

  final List<String> recommendations;

  // ============================================================
  // CARE SCHEDULE
  // ============================================================

  final List<CareTask> careSchedule;

  // ============================================================
  // METADATA
  // ============================================================

  final DateTime generatedAt;

  // ============================================================
  // IMAGE
  // ============================================================

  final String? imagePath;
  final Uint8List? imageBytes;

  final bool generatedFromImage;

  final String? imageSource;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const PlantCareReport({
    required this.plantName,
    required this.scientificName,
    required this.category,
    required this.identificationConfidence,
    required this.healthStatus,
    required this.healthScore,
    required this.overview,
    required this.sunlight,
    required this.watering,
    required this.soil,
    required this.temperature,
    required this.humidity,
    required this.fertilizer,
    required this.symptoms,
    required this.recommendations,
    required this.careSchedule,
    required this.generatedAt,
    this.imagePath,
    this.imageBytes,
    this.generatedFromImage = false,
    this.imageSource,
  });

  // ============================================================
  // CONFIDENCE
  // ============================================================

  double get normalizedConfidence {
    final value = identificationConfidence;

    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }

    return value.clamp(0.0, 1.0);
  }

  int get confidencePercentage {
    return (normalizedConfidence * 100)
        .round()
        .clamp(0, 100);
  }

  String get confidenceText {
    return '$confidencePercentage%';
  }

  // ============================================================
  // HEALTH SCORE
  // ============================================================

  int get normalizedHealthScore {
    return healthScore.clamp(0, 100);
  }

  String get healthScoreText {
    return '$normalizedHealthScore%';
  }

  // ============================================================
  // IMAGE
  // ============================================================

  bool get hasImage {
    return imageBytes != null &&
        imageBytes!.isNotEmpty;
  }

  bool get isCameraReport {
    return generatedFromImage &&
        imageSource == 'camera';
  }

  bool get isGalleryReport {
    return generatedFromImage &&
        imageSource == 'gallery';
  }

  // ============================================================
  // HEALTH STATUS
  // ============================================================

  String get normalizedHealthStatus {
    return healthStatus
        .trim()
        .toLowerCase();
  }

  bool get isHealthy {
    final status = normalizedHealthStatus;

    if (status.isEmpty) {
      return normalizedHealthScore >= 80;
    }

    const healthyStatuses = {
      'healthy',
      'good',
      'excellent',
      'normal',
      'no significant issues',
      'no significant visible issues',
      'no visible problems',
      'healthy condition',
    };

    if (healthyStatuses.contains(status)) {
      return true;
    }

    if (normalizedHealthScore >= 80 &&
        !status.contains('poor') &&
        !status.contains('critical') &&
        !status.contains('disease') &&
        !status.contains('infected') &&
        !status.contains('unhealthy')) {
      return true;
    }

    return false;
  }

  bool get needsAttention {
    return !isHealthy;
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool get hasValidPlantIdentification {
    return plantName.trim().isNotEmpty &&
        plantName.trim().toLowerCase() !=
            'unknown plant' &&
        normalizedConfidence > 0;
  }

  bool get isAiImageReport {
    return generatedFromImage && hasImage;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PlantCareReport copyWith({
    String? plantName,
    String? scientificName,
    String? category,
    double? identificationConfidence,
    String? healthStatus,
    int? healthScore,
    String? overview,
    String? sunlight,
    String? watering,
    String? soil,
    String? temperature,
    String? humidity,
    String? fertilizer,
    List<String>? symptoms,
    List<String>? recommendations,
    List<CareTask>? careSchedule,
    DateTime? generatedAt,
    String? imagePath,
    Uint8List? imageBytes,
    bool? generatedFromImage,
    String? imageSource,
    bool clearImage = false,
    bool clearImageSource = false,
  }) {
    return PlantCareReport(
      plantName:
          plantName ?? this.plantName,
      scientificName:
          scientificName ?? this.scientificName,
      category:
          category ?? this.category,
      identificationConfidence:
          identificationConfidence ??
              this.identificationConfidence,
      healthStatus:
          healthStatus ?? this.healthStatus,
      healthScore:
          healthScore ?? this.healthScore,
      overview:
          overview ?? this.overview,
      sunlight:
          sunlight ?? this.sunlight,
      watering:
          watering ?? this.watering,
      soil:
          soil ?? this.soil,
      temperature:
          temperature ?? this.temperature,
      humidity:
          humidity ?? this.humidity,
      fertilizer:
          fertilizer ?? this.fertilizer,
      symptoms:
          symptoms ?? this.symptoms,
      recommendations:
          recommendations ?? this.recommendations,
      careSchedule:
          careSchedule ?? this.careSchedule,
      generatedAt:
          generatedAt ?? this.generatedAt,

      imagePath: clearImage
          ? null
          : imagePath ?? this.imagePath,

      imageBytes: clearImage
          ? null
          : imageBytes ?? this.imageBytes,

      generatedFromImage:
          generatedFromImage ??
              this.generatedFromImage,

      imageSource: clearImageSource
          ? null
          : imageSource ?? this.imageSource,
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  factory PlantCareReport.empty() {
    return PlantCareReport(
      plantName: 'Unknown Plant',
      scientificName:
          'Scientific name unavailable',
      category: 'Unknown',
      identificationConfidence: 0.0,
      healthStatus: 'Unknown',
      healthScore: 0,
      overview:
          'No plant analysis has been generated yet.',
      sunlight:
          'Sunlight information is not available.',
      watering:
          'Watering information is not available.',
      soil:
          'Soil information is not available.',
      temperature:
          'Temperature information is not available.',
      humidity:
          'Humidity information is not available.',
      fertilizer:
          'Fertilizer information is not available.',
      symptoms: const [],
      recommendations: const [],
      careSchedule: const [],
      generatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PlantCareReport('
        'plantName: $plantName, '
        'scientificName: $scientificName, '
        'confidence: $confidenceText, '
        'healthStatus: $healthStatus, '
        'healthScore: $normalizedHealthScore'
        ')';
  }
}

// ================================================================
// CARE TASK
// ================================================================

class CareTask {
  final String title;
  final String description;
  final String frequency;
  final String icon;

  const CareTask({
    required this.title,
    required this.description,
    required this.frequency,
    required this.icon,
  });

  CareTask copyWith({
    String? title,
    String? description,
    String? frequency,
    String? icon,
  }) {
    return CareTask(
      title: title ?? this.title,
      description:
          description ?? this.description,
      frequency:
          frequency ?? this.frequency,
      icon: icon ?? this.icon,
    );
  }

  bool get isValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'CareTask('
        'title: $title, '
        'frequency: $frequency'
        ')';
  }
}