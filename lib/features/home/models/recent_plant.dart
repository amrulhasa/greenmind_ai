class RecentPlant {
  // ============================================================
  // SCAN TYPE
  // ============================================================

  static const String identification = 'identification';

  static const String diseaseDetection = 'disease';

  final String scanType;

  // ============================================================
  // PLANT INFORMATION
  // ============================================================

  final String plantName;
  final String scientificName;

  // ============================================================
  // DISEASE INFORMATION
  // ============================================================

  final String diseaseName;
  final String symptoms;
  final String treatment;
  final String prevention;

  // ============================================================
  // COMMON INFORMATION
  // ============================================================

  final double confidence;
  final String description;
  final String careTips;
  final bool isHealthy;
  final DateTime identifiedAt;

  // ============================================================
  // IMAGE
  // ============================================================

  final String? imageBase64;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const RecentPlant({
    this.scanType = identification,
    required this.plantName,
    required this.scientificName,
    this.diseaseName = '',
    this.symptoms = '',
    this.treatment = '',
    this.prevention = '',
    required this.confidence,
    required this.description,
    required this.careTips,
    required this.isHealthy,
    required this.identifiedAt,
    this.imageBase64,
  });

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isDiseaseDetection =>
      scanType == diseaseDetection;

  bool get isIdentification =>
      scanType == identification;

  bool get hasImage =>
      imageBase64 != null &&
      imageBase64!.trim().isNotEmpty;

  bool get hasDisease =>
      diseaseName.trim().isNotEmpty;

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'scanType': scanType,
      'plantName': plantName,
      'scientificName': scientificName,
      'diseaseName': diseaseName,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'confidence': confidence,
      'description': description,
      'careTips': careTips,
      'isHealthy': isHealthy,
      'identifiedAt': identifiedAt.toIso8601String(),
      'imageBase64': imageBase64,
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory RecentPlant.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentPlant(
      scanType: _parseScanType(
        json['scanType'],
      ),
      plantName: _stringValue(
        json['plantName'],
        fallback: 'Unknown Plant',
      ),
      scientificName: _stringValue(
        json['scientificName'],
      ),
      diseaseName: _stringValue(
        json['diseaseName'],
      ),
      symptoms: _stringValue(
        json['symptoms'],
      ),
      treatment: _stringValue(
        json['treatment'],
      ),
      prevention: _stringValue(
        json['prevention'],
      ),
      confidence: _parseConfidence(
        json['confidence'],
      ),
      description: _stringValue(
        json['description'],
      ),
      careTips: _stringValue(
        json['careTips'],
      ),
      isHealthy: _parseBool(
        json['isHealthy'],
      ),
      identifiedAt: _parseDateTime(
        json['identifiedAt'],
      ),
      imageBase64: _parseNullableString(
        json['imageBase64'],
      ),
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  RecentPlant copyWith({
    String? scanType,
    String? plantName,
    String? scientificName,
    String? diseaseName,
    String? symptoms,
    String? treatment,
    String? prevention,
    double? confidence,
    String? description,
    String? careTips,
    bool? isHealthy,
    DateTime? identifiedAt,
    String? imageBase64,
    bool clearImage = false,
  }) {
    return RecentPlant(
      scanType: scanType ?? this.scanType,
      plantName: plantName ?? this.plantName,
      scientificName:
          scientificName ?? this.scientificName,
      diseaseName:
          diseaseName ?? this.diseaseName,
      symptoms:
          symptoms ?? this.symptoms,
      treatment:
          treatment ?? this.treatment,
      prevention:
          prevention ?? this.prevention,
      confidence:
          confidence ?? this.confidence,
      description:
          description ?? this.description,
      careTips:
          careTips ?? this.careTips,
      isHealthy:
          isHealthy ?? this.isHealthy,
      identifiedAt:
          identifiedAt ?? this.identifiedAt,
      imageBase64: clearImage
          ? null
          : imageBase64 ?? this.imageBase64,
    );
  }

  // ============================================================
  // SCAN TYPE PARSER
  // ============================================================

  static String _parseScanType(
    dynamic value,
  ) {
    final normalized =
        value
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    if (normalized == diseaseDetection ||
        normalized == 'disease_detection' ||
        normalized == 'disease detection') {
      return diseaseDetection;
    }

    return identification;
  }

  // ============================================================
  // STRING PARSER
  // ============================================================

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  // ============================================================
  // NULLABLE STRING
  // ============================================================

  static String? _parseNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // CONFIDENCE
  // ============================================================

  static double _parseConfidence(
    dynamic value,
  ) {
    double confidence;

    if (value is num) {
      confidence = value.toDouble();
    } else {
      confidence =
          double.tryParse(
                value?.toString().trim() ?? '',
              ) ??
              0.0;
    }

    if (confidence < 0) {
      return 0.0;
    }

    if (confidence > 100) {
      return 100.0;
    }

    return confidence;
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  static bool _parseBool(
    dynamic value,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;

        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }

    return false;
  }

  // ============================================================
  // DATETIME
  // ============================================================

  static DateTime _parseDateTime(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    try {
      final converted = value?.toDate();

      if (converted is DateTime) {
        return converted;
      }
    } catch (_) {}

    if (value != null) {
      final parsed = DateTime.tryParse(
        value.toString(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }
}