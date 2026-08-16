class IdentifyResult {
  final String plantName;
  final String scientificName;
  final double confidence;
  final String description;
  final String careTips;
  final bool isHealthy;

  const IdentifyResult({
    required this.plantName,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.careTips,
    required this.isHealthy,
  });

  factory IdentifyResult.empty() {
    return const IdentifyResult(
      plantName: '',
      scientificName: '',
      confidence: 0,
      description: '',
      careTips: '',
      isHealthy: true,
    );
  }

  IdentifyResult copyWith({
    String? plantName,
    String? scientificName,
    double? confidence,
    String? description,
    String? careTips,
    bool? isHealthy,
  }) {
    return IdentifyResult(
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      careTips: careTips ?? this.careTips,
      isHealthy: isHealthy ?? this.isHealthy,
    );
  }

  @override
  String toString() {
    return 'IdentifyResult('
        'plantName: $plantName, '
        'scientificName: $scientificName, '
        'confidence: $confidence, '
        'isHealthy: $isHealthy'
        ')';
  }
}