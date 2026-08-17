class RecentPlant {
  // ============================================================
  // SCAN TYPE
  // ============================================================

  static const String identification =
      'identification';

  static const String diseaseDetection =
      'disease';

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

  // Compressed Base64 image.
  final String? imageBase64;

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
  // HELPERS
  // ============================================================

  bool get isDiseaseDetection {
    return scanType == diseaseDetection;
  }

  bool get isIdentification {
    return scanType == identification;
  }

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
      'identifiedAt':
          identifiedAt.toIso8601String(),
      'imageBase64': imageBase64,
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory RecentPlant.fromJson(
    Map<String, dynamic> json,
  ) {
    final storedScanType =
        json['scanType']?.toString();

    return RecentPlant(
      scanType:
          storedScanType ==
                  diseaseDetection
              ? diseaseDetection
              : identification,

      plantName:
          json['plantName']?.toString() ??
              'Unknown Plant',

      scientificName:
          json['scientificName']?.toString() ??
              '',

      diseaseName:
          json['diseaseName']?.toString() ??
              '',

      symptoms:
          json['symptoms']?.toString() ??
              '',

      treatment:
          json['treatment']?.toString() ??
              '',

      prevention:
          json['prevention']?.toString() ??
              '',

      confidence:
          (json['confidence'] as num?)
                  ?.toDouble() ??
              0.0,

      description:
          json['description']?.toString() ??
              '',

      careTips:
          json['careTips']?.toString() ??
              '',

      isHealthy:
          json['isHealthy'] == true,

      identifiedAt:
          DateTime.tryParse(
                json['identifiedAt']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      imageBase64:
          json['imageBase64']?.toString(),
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
  }) {
    return RecentPlant(
      scanType:
          scanType ?? this.scanType,

      plantName:
          plantName ?? this.plantName,

      scientificName:
          scientificName ??
              this.scientificName,

      diseaseName:
          diseaseName ??
              this.diseaseName,

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

      imageBase64:
          imageBase64 ?? this.imageBase64,
    );
  }
}