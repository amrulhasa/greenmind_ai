class RecentPlant {
  final String plantName;
  final String scientificName;
  final double confidence;
  final String description;
  final String careTips;
  final bool isHealthy;
  final DateTime identifiedAt;

  // Compressed Base64 image.
  final String? imageBase64;

  const RecentPlant({
    required this.plantName,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.careTips,
    required this.isHealthy,
    required this.identifiedAt,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'plantName': plantName,
      'scientificName': scientificName,
      'confidence': confidence,
      'description': description,
      'careTips': careTips,
      'isHealthy': isHealthy,
      'identifiedAt': identifiedAt.toIso8601String(),
      'imageBase64': imageBase64,
    };
  }

  factory RecentPlant.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentPlant(
      plantName:
          json['plantName'] as String? ??
              'Unknown Plant',
      scientificName:
          json['scientificName'] as String? ??
              '',
      confidence:
          (json['confidence'] as num?)
                  ?.toDouble() ??
              0,
      description:
          json['description'] as String? ??
              '',
      careTips:
          json['careTips'] as String? ??
              '',
      isHealthy:
          json['isHealthy'] as bool? ??
              true,
      identifiedAt:
          DateTime.tryParse(
                json['identifiedAt']
                        as String? ??
                    '',
              ) ??
              DateTime.now(),
      imageBase64:
          json['imageBase64'] as String?,
    );
  }
}