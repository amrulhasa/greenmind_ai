/// Represents a nearby plant nursery, garden centre, or plant shop.
///
/// Data can come from OpenStreetMap / Overpass or another
/// location provider in the future.
///
/// External/provider data is kept nullable where the
/// provider may not have complete information.
class Nursery {
  const Nursery({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address = 'Address unavailable',
    this.distanceMeters,
    this.rating,
    this.userRatingsTotal,
    this.isOpen,
    this.phoneNumber,
    this.website,
    this.photoUrl,
    this.placeType,
    this.openingHours,
    this.source,
  });

  // ============================================================
  // IDENTITY
  // ============================================================

  final String id;

  final String name;

  // ============================================================
  // LOCATION
  // ============================================================

  final double latitude;

  final double longitude;

  final String address;

  /// Distance from user's current location in meters.
  final double? distanceMeters;

  // ============================================================
  // RATING
  // ============================================================

  final double? rating;

  final int? userRatingsTotal;

  // ============================================================
  // OPEN STATUS
  // ============================================================

  /// true  = open
  /// false = closed
  /// null  = unknown / unavailable
  final bool? isOpen;

  /// Original OSM opening_hours value.
  ///
  /// Example:
  /// "Mo-Sa 09:00-20:00"
  final String? openingHours;

  // ============================================================
  // CONTACT
  // ============================================================

  final String? phoneNumber;

  final String? website;

  // ============================================================
  // MEDIA
  // ============================================================

  final String? photoUrl;

  // ============================================================
  // CATEGORY / SOURCE
  // ============================================================

  final String? placeType;

  /// Data provider/source.
  ///
  /// Example:
  /// "OpenStreetMap"
  final String? source;

  // ============================================================
  // COMPUTED VALUES
  // ============================================================

  /// Distance in kilometres.
  double? get distanceKm {
    final meters = distanceMeters;

    if (meters == null) {
      return null;
    }

    return meters / 1000.0;
  }

  // ============================================================
  // DISTANCE LABEL
  // ============================================================

  String get distanceLabel {
    final meters = distanceMeters;

    if (meters == null) {
      return 'Distance unavailable';
    }

    if (meters < 1000) {
      return '${meters.round()} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ============================================================
  // RATING LABEL
  // ============================================================

  String get ratingLabel {
    final value = rating;

    if (value == null) {
      return 'No rating';
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // OPEN STATUS LABEL
  // ============================================================

  String get openStatusLabel {
    if (isOpen == true) {
      return 'Open now';
    }

    if (isOpen == false) {
      return 'Closed';
    }

    return 'Hours unavailable';
  }

  // ============================================================
  // OPENING HOURS LABEL
  // ============================================================

  String get openingHoursLabel {
    final value = openingHours;

    if (value == null ||
        value.trim().isEmpty) {
      return 'Hours unavailable';
    }

    return value.trim();
  }

  // ============================================================
  // CATEGORY LABEL
  // ============================================================

  String get categoryLabel {
    switch (placeType?.toLowerCase()) {
      case 'plant_nursery':
      case 'nursery':
        return 'Plant Nursery';

      case 'garden_centre':
      case 'garden_center':
        return 'Garden Centre';

      case 'plants':
      case 'plant_shop':
        return 'Plant Shop';

      case 'florist':
        return 'Flower & Plant Shop';

      default:
        return 'Plant Shop';
    }
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Nursery copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    double? distanceMeters,
    double? rating,
    int? userRatingsTotal,
    bool? isOpen,
    String? phoneNumber,
    String? website,
    String? photoUrl,
    String? placeType,
    String? openingHours,
    String? source,
  }) {
    return Nursery(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      distanceMeters:
          distanceMeters ??
              this.distanceMeters,
      rating:
          rating ?? this.rating,
      userRatingsTotal:
          userRatingsTotal ??
              this.userRatingsTotal,
      isOpen:
          isOpen ?? this.isOpen,
      phoneNumber:
          phoneNumber ?? this.phoneNumber,
      website:
          website ?? this.website,
      photoUrl:
          photoUrl ?? this.photoUrl,
      placeType:
          placeType ?? this.placeType,
      openingHours:
          openingHours ??
              this.openingHours,
      source:
          source ?? this.source,
    );
  }

  // ============================================================
  // MAP -> MODEL
  // ============================================================

  factory Nursery.fromMap(
    Map<String, dynamic> map,
  ) {
    return Nursery(
      id: _readString(
        map['id'],
        fallback: 'unknown',
      ),

      name: _readString(
        map['name'],
        fallback: 'Plant Shop',
      ),

      latitude: _readDouble(
        map['latitude'],
        fallback: 0.0,
      ),

      longitude: _readDouble(
        map['longitude'],
        fallback: 0.0,
      ),

      address: _readString(
        map['address'],
        fallback:
            'Address unavailable',
      ),

      distanceMeters:
          _readNullableDouble(
        map['distanceMeters'],
      ),

      rating:
          _readNullableDouble(
        map['rating'],
      ),

      userRatingsTotal:
          _readNullableInt(
        map['userRatingsTotal'],
      ),

      isOpen:
          _readNullableBool(
        map['isOpen'],
      ),

      phoneNumber:
          _readNullableString(
        map['phoneNumber'],
      ),

      website:
          _readNullableString(
        map['website'],
      ),

      photoUrl:
          _readNullableString(
        map['photoUrl'],
      ),

      placeType:
          _readNullableString(
        map['placeType'],
      ),

      openingHours:
          _readNullableString(
        map['openingHours'],
      ),

      source:
          _readNullableString(
        map['source'],
      ),
    );
  }

  // ============================================================
  // MODEL -> MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'distanceMeters':
          distanceMeters,
      'rating': rating,
      'userRatingsTotal':
          userRatingsTotal,
      'isOpen': isOpen,
      'phoneNumber':
          phoneNumber,
      'website':
          website,
      'photoUrl':
          photoUrl,
      'placeType':
          placeType,
      'openingHours':
          openingHours,
      'source':
          source,
    };
  }

  // ============================================================
  // JSON COMPATIBILITY
  // ============================================================

  factory Nursery.fromJson(
    Map<String, dynamic> json,
  ) {
    return Nursery.fromMap(json);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  // ============================================================
  // EQUALITY
  // ============================================================

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is Nursery &&
        other.id == id &&
        other.name == name &&
        other.latitude ==
            latitude &&
        other.longitude ==
            longitude &&
        other.address ==
            address &&
        other.distanceMeters ==
            distanceMeters &&
        other.rating ==
            rating &&
        other.userRatingsTotal ==
            userRatingsTotal &&
        other.isOpen ==
            isOpen &&
        other.phoneNumber ==
            phoneNumber &&
        other.website ==
            website &&
        other.photoUrl ==
            photoUrl &&
        other.placeType ==
            placeType &&
        other.openingHours ==
            openingHours &&
        other.source ==
            source;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      latitude,
      longitude,
      address,
      distanceMeters,
      rating,
      userRatingsTotal,
      isOpen,
      phoneNumber,
      website,
      photoUrl,
      placeType,
      openingHours,
      source,
    );
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'Nursery('
        'id: $id, '
        'name: $name, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'address: $address, '
        'distanceMeters: $distanceMeters, '
        'rating: $rating, '
        'userRatingsTotal: $userRatingsTotal, '
        'isOpen: $isOpen, '
        'phoneNumber: $phoneNumber, '
        'website: $website, '
        'photoUrl: $photoUrl, '
        'placeType: $placeType, '
        'openingHours: $openingHours, '
        'source: $source'
        ')';
  }

  // ============================================================
  // PRIVATE PARSING HELPERS
  // ============================================================

  static String _readString(
    dynamic value, {
    required String fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  static String? _readNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static double _readDouble(
    dynamic value, {
    required double fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString().trim(),
        ) ??
        fallback;
  }

  static double? _readNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    );
  }

  static int? _readNullableInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString().trim(),
    );
  }

  static bool? _readNullableBool(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    final text =
        value.toString()
            .trim()
            .toLowerCase();

    if (text == 'true' ||
        text == 'yes' ||
        text == 'open' ||
        text == '1') {
      return true;
    }

    if (text == 'false' ||
        text == 'no' ||
        text == 'closed' ||
        text == '0') {
      return false;
    }

    return null;
  }
}