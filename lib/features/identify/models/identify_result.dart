class IdentifyResult {
  // ============================================================
  // FIELDS
  // ============================================================

  final String plantName;
  final String scientificName;
  final double confidence;
  final String description;
  final String careTips;
  final bool isHealthy;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const IdentifyResult({
    required this.plantName,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.careTips,
    required this.isHealthy,
  });

  // ============================================================
  // EMPTY RESULT
  // ============================================================

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

  // ============================================================
  // PLANT NAME
  // ============================================================

  bool get hasPlantName {
    final name = plantName.trim();

    if (name.isEmpty) {
      return false;
    }

    // Treat these as invalid identification results.
    final normalized =
        name.toLowerCase();

    return normalized != 'unknown plant' &&
        normalized != 'unknown' &&
        normalized != 'n/a' &&
        normalized != 'not identified';
  }

  // ============================================================
  // SCIENTIFIC NAME
  // ============================================================

  bool get hasScientificName {
    final name =
        scientificName.trim();

    if (name.isEmpty) {
      return false;
    }

    final normalized =
        name.toLowerCase();

    return normalized != 'unknown' &&
        normalized != 'n/a' &&
        normalized != 'not provided' &&
        normalized != 'not available';
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  bool get hasDescription {
    return description.trim().isNotEmpty;
  }

  // ============================================================
  // CARE TIPS
  // ============================================================

  bool get hasCareTips {
    return careTips.trim().isNotEmpty;
  }

  // ============================================================
  // NORMALIZED CONFIDENCE
  // ============================================================

  /// Confidence is stored as a percentage:
  ///
  /// 0   = no confidence
  /// 100 = maximum confidence
  ///
  /// This getter protects the UI and other layers from
  /// invalid NaN, infinite, negative, or >100 values.
  double get normalizedConfidence {
    if (confidence.isNaN ||
        confidence.isInfinite) {
      return 0.0;
    }

    if (confidence <= 0) {
      return 0.0;
    }

    if (confidence >= 100) {
      return 100.0;
    }

    return confidence;
  }

  // ============================================================
  // CONFIDENCE TEXT
  // ============================================================

  String get confidenceText {
    return '${normalizedConfidence.toStringAsFixed(0)}%';
  }

  // ============================================================
  // CONFIDENCE LEVEL
  // ============================================================

  String get confidenceLevel {
    final value =
        normalizedConfidence;

    if (value >= 85) {
      return 'High';
    }

    if (value >= 60) {
      return 'Moderate';
    }

    if (value >= 30) {
      return 'Low';
    }

    return 'Very Low';
  }

  // ============================================================
  // VALID RESULT
  // ============================================================

  bool get isValid {
    return hasPlantName &&
        normalizedConfidence > 0;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  IdentifyResult copyWith({
    String? plantName,
    String? scientificName,
    double? confidence,
    String? description,
    String? careTips,
    bool? isHealthy,
  }) {
    return IdentifyResult(
      plantName:
          plantName ?? this.plantName,

      scientificName:
          scientificName ??
              this.scientificName,

      confidence:
          confidence ??
              this.confidence,

      description:
          description ??
              this.description,

      careTips:
          careTips ??
              this.careTips,

      isHealthy:
          isHealthy ??
              this.isHealthy,
    );
  }

  // ============================================================
  // TO STRING
  // ============================================================

  @override
  String toString() {
    return 'IdentifyResult('
        'plantName: $plantName, '
        'scientificName: $scientificName, '
        'confidence: ${normalizedConfidence.toStringAsFixed(1)}, '
        'isHealthy: $isHealthy'
        ')';
  }
}