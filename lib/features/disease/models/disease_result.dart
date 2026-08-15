class DiseaseResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final bool isHealthy;

  const DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.isHealthy,
  });

  // ============================================================
  // EMPTY RESULT
  // ============================================================

  factory DiseaseResult.empty() {
    return const DiseaseResult(
      diseaseName: '',
      confidence: 0,
      description: '',
      symptoms: '',
      treatment: '',
      prevention: '',
      isHealthy: true,
    );
  }

  // ============================================================
  // TO JSON
  // Used for Persistent Cache
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'description': description,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'isHealthy': isHealthy,
    };
  }

  // ============================================================
  // FROM JSON
  // Used to restore Persistent Cache
  // ============================================================

  factory DiseaseResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiseaseResult(
      diseaseName:
          json['diseaseName']?.toString() ?? '',

      confidence:
          (json['confidence'] as num?)?.toDouble() ?? 0.0,

      description:
          json['description']?.toString() ?? '',

      symptoms:
          json['symptoms']?.toString() ?? '',

      treatment:
          json['treatment']?.toString() ?? '',

      prevention:
          json['prevention']?.toString() ?? '',

      isHealthy:
          json['isHealthy'] == true,
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  DiseaseResult copyWith({
    String? diseaseName,
    double? confidence,
    String? description,
    String? symptoms,
    String? treatment,
    String? prevention,
    bool? isHealthy,
  }) {
    return DiseaseResult(
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      prevention: prevention ?? this.prevention,
      isHealthy: isHealthy ?? this.isHealthy,
    );
  }
}