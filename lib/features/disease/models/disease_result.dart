class DiseaseResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final String treatment;
  final String prevention;
  final bool isHealthy;

  const DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.treatment,
    required this.prevention,
    required this.isHealthy,
  });

  factory DiseaseResult.empty() {
    return const DiseaseResult(
      diseaseName: '',
      confidence: 0,
      description: '',
      treatment: '',
      prevention: '',
      isHealthy: false,
    );
  }

  DiseaseResult copyWith({
    String? diseaseName,
    double? confidence,
    String? description,
    String? treatment,
    String? prevention,
    bool? isHealthy,
  }) {
    return DiseaseResult(
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      treatment: treatment ?? this.treatment,
      prevention: prevention ?? this.prevention,
      isHealthy: isHealthy ?? this.isHealthy,
    );
  }
}