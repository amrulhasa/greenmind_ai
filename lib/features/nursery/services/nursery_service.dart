import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/nursery.dart';

/// GreenMind AI - Nearby Nursery Service
///
/// Data source:
///   OpenStreetMap + Overpass API
///
/// Responsibilities:
/// - Search nearby plant nurseries
/// - Search garden centres
/// - Search plant shops
/// - Parse OSM elements
/// - Calculate distance
/// - Remove duplicates
/// - Handle Overpass failures
class NurseryService {
  NurseryService({
    Dio? dio,
    Logger? logger,
  })  : _dio = dio ?? _createDio(),
        _logger = logger ?? Logger();

  final Dio _dio;
  final Logger _logger;

  // ---------------------------------------------------------------------------
  // DEFAULTS
  // ---------------------------------------------------------------------------

  static const double defaultRadiusMeters = 5000.0;

  static const int defaultMaxResults = 50;

  // ---------------------------------------------------------------------------
  // OVERPASS ENDPOINTS
  // ---------------------------------------------------------------------------
  //
  // Keep this list small.
  // Requests are sequential, not parallel.
  //
  // Private.coffee documents this endpoint as a public global Overpass
  // instance and recommends POST where possible.
  // ---------------------------------------------------------------------------

  static const List<String> _overpassEndpoints = [
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  // ---------------------------------------------------------------------------
  // TIMEOUTS
  // ---------------------------------------------------------------------------

  static const Duration _connectTimeout =
      Duration(seconds: 8);

  static const Duration _sendTimeout =
      Duration(seconds: 8);

  static const Duration _receiveTimeout =
      Duration(seconds: 12);

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Future<List<Nursery>> searchNearbyNurseries({
    required double latitude,
    required double longitude,
    double radiusMeters = defaultRadiusMeters,
    int maxResults = defaultMaxResults,
  }) async {
    // -------------------------------------------------------------------------
    // VALIDATE LOCATION
    // -------------------------------------------------------------------------

    if (!_validCoordinates(
      latitude,
      longitude,
    )) {
      throw const NurserySearchException(
        'Invalid current location.',
      );
    }

    // -------------------------------------------------------------------------
    // NORMALIZE RADIUS
    // -------------------------------------------------------------------------

    final radius = radiusMeters
        .clamp(
          500.0,
          50000.0,
        )
        .toDouble();

    // -------------------------------------------------------------------------
    // NORMALIZE RESULT LIMIT
    // -------------------------------------------------------------------------

    final resultLimit = maxResults
        .clamp(
          1,
          defaultMaxResults,
        )
        .toInt();

    _logger.i(
      'Searching plant locations near '
      '($latitude, $longitude) '
      'within ${radius.toInt()} meters.',
    );

    // -------------------------------------------------------------------------
    // BUILD QUERY
    // -------------------------------------------------------------------------

    final query = _buildOverpassQuery(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radius,
    );

    Object? lastError;

    // -------------------------------------------------------------------------
    // TRY ENDPOINTS ONE BY ONE
    // -------------------------------------------------------------------------

    for (final endpoint in _overpassEndpoints) {
      try {
        _logger.d(
          'Trying Overpass endpoint: $endpoint',
        );

        final elements = await _requestOverpass(
          endpoint: endpoint,
          query: query,
        );

        // ---------------------------------------------------------------------
        // PARSE RESULTS
        // ---------------------------------------------------------------------

        final nurseries = <Nursery>[];

        for (final element in elements) {
          if (element is! Map) {
            continue;
          }

          try {
            final nursery = _parseNursery(
              Map<String, dynamic>.from(
                element,
              ),
              userLatitude: latitude,
              userLongitude: longitude,
            );

            if (nursery != null) {
              nurseries.add(nursery);
            }
          } catch (error, stackTrace) {
            _logger.w(
              'Failed to parse OSM nursery element.',
              error: error,
              stackTrace: stackTrace,
            );
          }
        }

        // ---------------------------------------------------------------------
        // REMOVE DUPLICATES
        // ---------------------------------------------------------------------

        final uniqueNurseries =
            _removeDuplicates(
          nurseries,
        );

        // ---------------------------------------------------------------------
        // SORT BY DISTANCE
        // ---------------------------------------------------------------------

        uniqueNurseries.sort(
          (a, b) {
            final distanceA =
                a.distanceMeters ??
                    double.infinity;

            final distanceB =
                b.distanceMeters ??
                    double.infinity;

            return distanceA.compareTo(
              distanceB,
            );
          },
        );

        // ---------------------------------------------------------------------
        // LIMIT
        // ---------------------------------------------------------------------

        final limited =
            uniqueNurseries.length > resultLimit
                ? uniqueNurseries.sublist(
                    0,
                    resultLimit,
                  )
                : uniqueNurseries;

        _logger.i(
          'Overpass success: '
          '${limited.length} nearby plant locations.',
        );

        return limited;
      } on NurserySearchException catch (error) {
        lastError = error;

        _logger.w(
          'Overpass endpoint failed: $endpoint',
          error: error,
        );
      } on DioException catch (error) {
        lastError = error;

        _logger.w(
          'Overpass network failure: $endpoint',
          error: error,
        );
      } catch (error, stackTrace) {
        lastError = error;

        _logger.w(
          'Unexpected Overpass failure: $endpoint',
          error: error,
          stackTrace: stackTrace,
        );
      }

      // Small delay before trying another public instance.
      await Future<void>.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // EVERYTHING FAILED
    // -------------------------------------------------------------------------

    if (lastError is NurserySearchException) {
      throw lastError;
    }

    throw NurserySearchException(
      _friendlyErrorMessage(
        lastError,
      ),
    );
  }

  // ===========================================================================
  // DIO
  // ===========================================================================

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        sendTimeout: _sendTimeout,
        receiveTimeout: _receiveTimeout,
        responseType: ResponseType.plain,
        headers: const {
          'Accept': 'application/json',
          'User-Agent':
              'GreenMindAI/1.0 '
              '(Flutter plant identification and care assistant)',
        },
      ),
    );
  }

  // ===========================================================================
  // OVERPASS QUERY
  // ===========================================================================

  String _buildOverpassQuery({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    final lat =
        latitude.toStringAsFixed(6);

    final lon =
        longitude.toStringAsFixed(6);

    final radius =
        radiusMeters
            .clamp(
              500.0,
              50000.0,
            )
            .toInt();

    return '''
[out:json][timeout:12];

(
  nwr["landuse"="plant_nursery"](
    around:$radius,$lat,$lon
  );

  nwr["shop"="garden_centre"](
    around:$radius,$lat,$lon
  );

  nwr["shop"="garden_center"](
    around:$radius,$lat,$lon
  );

  nwr["shop"="plants"](
    around:$radius,$lat,$lon
  );

  nwr["nursery"="yes"](
    around:$radius,$lat,$lon
  );
);

out center tags qt;
''';
  }

  // ===========================================================================
  // OVERPASS REQUEST
  // ===========================================================================

  Future<List<dynamic>> _requestOverpass({
    required String endpoint,
    required String query,
  }) async {
    try {
      // POST is preferable here because the complete Overpass query does not
      // need to be encoded into the URL.
      final response = await _dio.post(
        endpoint,
        data: <String, String>{
          'data': query,
        },
        options: Options(
          contentType:
              Headers.formUrlEncodedContentType,
          responseType:
              ResponseType.plain,

          // We want to inspect 4xx/5xx ourselves so that the endpoint
          // failover logic can work consistently.
          validateStatus: (_) => true,
        ),
      );

      // -----------------------------------------------------------------------
      // HTTP STATUS
      // -----------------------------------------------------------------------

      final status =
          response.statusCode;

      if (status == null) {
        throw const NurserySearchException(
          'No response received from the map service.',
        );
      }

      if (status < 200 ||
          status >= 300) {
        // Temporary server/rate-limit failures.
        if (status == 429 ||
            status == 502 ||
            status == 503 ||
            status == 504) {
          throw NurserySearchException(
            'Map service is temporarily busy '
            '(HTTP $status).',
          );
        }

        throw NurserySearchException(
          'Map service returned HTTP $status.',
        );
      }

      // -----------------------------------------------------------------------
      // RAW DATA
      // -----------------------------------------------------------------------

      final rawData =
          response.data;

      if (rawData == null) {
        throw const NurserySearchException(
          'The map service returned an empty response.',
        );
      }

      final text =
          rawData.toString().trim();

      if (text.isEmpty) {
        throw const NurserySearchException(
          'The map service returned an empty response.',
        );
      }

      // -----------------------------------------------------------------------
      // HTML ERROR RESPONSE
      // -----------------------------------------------------------------------

      final lower =
          text.toLowerCase();

      if (lower.startsWith('<html') ||
          lower.startsWith('<!doctype') ||
          lower.contains(
            '<title>osm3s response</title>',
          )) {
        throw const NurserySearchException(
          'The OpenStreetMap search server is currently busy.',
        );
      }

      // -----------------------------------------------------------------------
      // JSON
      // -----------------------------------------------------------------------

      dynamic decoded;

      try {
        decoded = jsonDecode(text);
      } catch (error, stackTrace) {
        _logger.w(
          'Unable to decode Overpass JSON.',
          error: error,
          stackTrace: stackTrace,
        );

        throw const NurserySearchException(
          'Invalid response received from the map service.',
        );
      }

      if (decoded is! Map) {
        throw const NurserySearchException(
          'Unexpected response from the map service.',
        );
      }

      final elements =
          decoded['elements'];

      if (elements is! List) {
        return const <dynamic>[];
      }

      return elements;
    } on DioException catch (error, stackTrace) {
      _logger.w(
        'Overpass network error: ${error.type}',
        error: error,
        stackTrace: stackTrace,
      );

      throw NurserySearchException(
        _dioErrorMessage(error),
      );
    }
  }

  // ===========================================================================
  // PARSE NURSERY
  // ===========================================================================

  Nursery? _parseNursery(
    Map<String, dynamic> element, {
    required double userLatitude,
    required double userLongitude,
  }) {
    final type =
        element['type']?.toString();

    final id =
        element['id']?.toString();

    if (type == null ||
        id == null ||
        id.isEmpty) {
      return null;
    }

    // -------------------------------------------------------------------------
    // TAGS
    // -------------------------------------------------------------------------

    final rawTags =
        element['tags'];

    final tags = rawTags is Map
        ? Map<String, dynamic>.from(
            rawTags,
          )
        : <String, dynamic>{};

    // -------------------------------------------------------------------------
    // VALIDATE CATEGORY
    // -------------------------------------------------------------------------

    if (!_isValidPlantLocation(tags)) {
      return null;
    }

    final category =
        _detectPlaceType(tags);

    // -------------------------------------------------------------------------
    // NAME
    // -------------------------------------------------------------------------

    final name =
        _firstNonEmpty([
      tags['name'],
      tags['name:en'],
      tags['official_name'],
      tags['brand'],
      tags['operator'],
    ]);

    final nurseryName =
        name ??
            _generateFallbackName(
              category,
            );

    // -------------------------------------------------------------------------
    // COORDINATES
    // -------------------------------------------------------------------------

    final coordinates =
        _extractCoordinates(
      element,
    );

    if (coordinates == null) {
      return null;
    }

    // -------------------------------------------------------------------------
    // DISTANCE
    // -------------------------------------------------------------------------

    final distanceMeters =
        _distanceInMeters(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude:
          coordinates.latitude,
      endLongitude:
          coordinates.longitude,
    );

    // -------------------------------------------------------------------------
    // OPENING HOURS
    // -------------------------------------------------------------------------

    final openingHours =
        _firstNonEmpty([
      tags['opening_hours'],
    ]);

    final isOpen =
        _parseOpeningStatus(
      openingHours,
    );

    // -------------------------------------------------------------------------
    // MODEL
    // -------------------------------------------------------------------------

    return Nursery(
      id: 'osm_${type}_$id',
      name: nurseryName,
      latitude:
          coordinates.latitude,
      longitude:
          coordinates.longitude,
      address:
          _buildAddress(tags),
      distanceMeters:
          distanceMeters,
      rating:
          _parseDouble(
        tags['rating'],
      ),
      userRatingsTotal:
          _parseInt(
        tags['rating_count'],
      ),
      isOpen: isOpen,
      phoneNumber:
          _firstNonEmpty([
        tags['phone'],
        tags['contact:phone'],
        tags['mobile'],
        tags['contact:mobile'],
      ]),
      website:
          _firstNonEmpty([
        tags['website'],
        tags['contact:website'],
        tags['url'],
      ]),
      photoUrl: null,
      placeType: category,
      openingHours:
          openingHours,
      source:
          'OpenStreetMap',
    );
  }

  // ===========================================================================
  // VALID PLANT LOCATION
  // ===========================================================================

  bool _isValidPlantLocation(
    Map<String, dynamic> tags,
  ) {
    final shop =
        tags['shop']
            ?.toString()
            .trim()
            .toLowerCase();

    final landuse =
        tags['landuse']
            ?.toString()
            .trim()
            .toLowerCase();

    final nursery =
        tags['nursery']
            ?.toString()
            .trim()
            .toLowerCase();

    return landuse ==
            'plant_nursery' ||
        shop ==
            'garden_centre' ||
        shop ==
            'garden_center' ||
        shop ==
            'plants' ||
        nursery ==
            'yes';
  }

  // ===========================================================================
  // COORDINATES
  // ===========================================================================

  _Coordinates? _extractCoordinates(
    Map<String, dynamic> element,
  ) {
    // NODE
    final lat =
        _parseDouble(
      element['lat'],
    );

    final lon =
        _parseDouble(
      element['lon'],
    );

    if (lat != null &&
        lon != null &&
        _validCoordinates(
          lat,
          lon,
        )) {
      return _Coordinates(
        latitude: lat,
        longitude: lon,
      );
    }

    // WAY / RELATION CENTER
    final rawCenter =
        element['center'];

    if (rawCenter is Map) {
      final center =
          Map<String, dynamic>.from(
        rawCenter,
      );

      final centerLat =
          _parseDouble(
        center['lat'],
      );

      final centerLon =
          _parseDouble(
        center['lon'],
      );

      if (centerLat != null &&
          centerLon != null &&
          _validCoordinates(
            centerLat,
            centerLon,
          )) {
        return _Coordinates(
          latitude: centerLat,
          longitude: centerLon,
        );
      }
    }

    return null;
  }

  // ===========================================================================
  // ADDRESS
  // ===========================================================================

  String _buildAddress(
    Map<String, dynamic> tags,
  ) {
    final fullAddress =
        _firstNonEmpty([
      tags['addr:full'],
      tags['address'],
    ]);

    if (fullAddress != null &&
        _isUsefulAddress(
          fullAddress,
        )) {
      return fullAddress;
    }

    final houseNumber =
        _firstNonEmpty([
      tags['addr:housenumber'],
    ]);

    final street =
        _firstNonEmpty([
      tags['addr:street'],
      tags['addr:road'],
    ]);

    final neighbourhood =
        _firstNonEmpty([
      tags['addr:neighbourhood'],
      tags['addr:suburb'],
      tags['addr:quarter'],
    ]);

    final city =
        _firstNonEmpty([
      tags['addr:city'],
      tags['addr:town'],
      tags['addr:village'],
      tags['addr:municipality'],
    ]);

    final district =
        _firstNonEmpty([
      tags['addr:district'],
      tags['addr:county'],
    ]);

    final postcode =
        _firstNonEmpty([
      tags['addr:postcode'],
    ]);

    final parts =
        <String>[];

    if (street != null) {
      if (houseNumber != null &&
          _isCleanHouseNumber(
            houseNumber,
          )) {
        parts.add(
          '$houseNumber $street',
        );
      } else {
        parts.add(street);
      }
    }

    for (final value in [
      neighbourhood,
      city,
      district,
      postcode,
    ]) {
      if (value != null) {
        _addUnique(
          parts,
          value,
        );
      }
    }

    if (parts.isEmpty) {
      return 'Address unavailable';
    }

    return parts.join(', ');
  }

  bool _isUsefulAddress(
    String value,
  ) {
    final cleaned =
        value.trim();

    if (cleaned.isEmpty) {
      return false;
    }

    if (cleaned.toLowerCase() ==
        'address unavailable') {
      return false;
    }

    if (RegExp(
      r'^[0-9\s,./-]+$',
    ).hasMatch(cleaned)) {
      return false;
    }

    return true;
  }

  bool _isCleanHouseNumber(
    String value,
  ) {
    final cleaned =
        value.trim();

    if (cleaned.isEmpty) {
      return false;
    }

    if (cleaned.contains(',')) {
      return false;
    }

    return true;
  }

  // ===========================================================================
  // PLACE TYPE
  // ===========================================================================

  String _detectPlaceType(
    Map<String, dynamic> tags,
  ) {
    final shop =
        tags['shop']
            ?.toString()
            .trim()
            .toLowerCase();

    final landuse =
        tags['landuse']
            ?.toString()
            .trim()
            .toLowerCase();

    final nursery =
        tags['nursery']
            ?.toString()
            .trim()
            .toLowerCase();

    if (landuse ==
            'plant_nursery' ||
        nursery ==
            'yes') {
      return 'Plant Nursery';
    }

    if (shop ==
            'garden_centre' ||
        shop ==
            'garden_center') {
      return 'Garden Centre';
    }

    return 'Plant Shop';
  }

  String _generateFallbackName(
    String category,
  ) {
    return category;
  }

  // ===========================================================================
  // OPENING STATUS
  // ===========================================================================

  bool? _parseOpeningStatus(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final openingHours =
        value.toString().trim();

    if (openingHours.isEmpty) {
      return null;
    }

    final lower =
        openingHours.toLowerCase();

    if (lower == '24/7') {
      return true;
    }

    if (lower == 'closed') {
      return false;
    }

    // Do not guess complex OSM opening_hours expressions.
    return null;
  }

  // ===========================================================================
  // REMOVE DUPLICATES
  // ===========================================================================

  List<Nursery> _removeDuplicates(
    List<Nursery> nurseries,
  ) {
    final seen =
        <String>{};

    final result =
        <Nursery>[];

    for (final nursery
        in nurseries) {
      final key =
          _duplicateKey(
        nursery,
      );

      if (seen.add(key)) {
        result.add(nursery);
      }
    }

    return result;
  }

  String _duplicateKey(
    Nursery nursery,
  ) {
    final normalizedName =
        nursery.name
            .trim()
            .toLowerCase();

    final lat =
        nursery.latitude
            .toStringAsFixed(5);

    final lon =
        nursery.longitude
            .toStringAsFixed(5);

    return '$normalizedName|$lat|$lon';
  }

  // ===========================================================================
  // DISTANCE
  // ===========================================================================

  double _distanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const earthRadius =
        6371000.0;

    final lat1 =
        _degreesToRadians(
      startLatitude,
    );

    final lat2 =
        _degreesToRadians(
      endLatitude,
    );

    final deltaLat =
        _degreesToRadians(
      endLatitude -
          startLatitude,
    );

    final deltaLon =
        _degreesToRadians(
      endLongitude -
          startLongitude,
    );

    final sinLat =
        math.sin(
      deltaLat / 2,
    );

    final sinLon =
        math.sin(
      deltaLon / 2,
    );

    final a =
        sinLat * sinLat +
            math.cos(lat1) *
                math.cos(lat2) *
                sinLon *
                sinLon;

    final safeA =
        a.clamp(
      0.0,
      1.0,
    );

    final c =
        2 *
            math.atan2(
              math.sqrt(
                safeA,
              ),
              math.sqrt(
                1 - safeA,
              ),
            );

    return earthRadius * c;
  }

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees *
        math.pi /
        180.0;
  }

  // ===========================================================================
  // VALID COORDINATES
  // ===========================================================================

  bool _validCoordinates(
    double latitude,
    double longitude,
  ) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 &&
            longitude == 0);
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void _addUnique(
    List<String> list,
    String value,
  ) {
    if (!list.contains(value)) {
      list.add(value);
    }
  }

  String? _firstNonEmpty(
    List<dynamic> values,
  ) {
    for (final value in values) {
      if (value == null) {
        continue;
      }

      final text =
          value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  double? _parseDouble(
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

  int? _parseInt(
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

  // ===========================================================================
  // DIO ERROR MESSAGE
  // ===========================================================================

  String _dioErrorMessage(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'The map server took too long to connect.';

      case DioExceptionType.sendTimeout:
        return 'The map request timed out.';

      case DioExceptionType.receiveTimeout:
        return 'The map server took too long to send data.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the map service.';

      case DioExceptionType.badResponse:
        final status =
            error.response?.statusCode;

        if (status != null) {
          return 'Map service returned HTTP $status.';
        }

        return 'The map service returned an invalid response.';

      case DioExceptionType.cancel:
        return 'The map search was cancelled.';

      case DioExceptionType.badCertificate:
        return 'The map service certificate could not be verified.';

      case DioExceptionType.transformTimeout:
        return 'The map response took too long to process.';

      case DioExceptionType.unknown:
        return error.message ??
            'Unable to connect to the map service.';
    }
  }

  String _friendlyErrorMessage(
    Object? error,
  ) {
    if (error == null) {
      return 'Unable to find nearby nurseries.';
    }

    if (error is NurserySearchException) {
      return error.message;
    }

    if (error is DioException) {
      return _dioErrorMessage(
        error,
      );
    }

    return 'Unable to find nearby nurseries right now. '
        'Please try again.';
  }
}

// ============================================================================
// COORDINATES
// ============================================================================

class _Coordinates {
  const _Coordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

// ============================================================================
// BASE EXCEPTION
// ============================================================================

abstract class NurseryException
    implements Exception {
  const NurseryException(
    this.message,
  );

  final String message;

  @override
  String toString() {
    return message;
  }
}

// ============================================================================
// SEARCH EXCEPTION
// ============================================================================

class NurserySearchException
    extends NurseryException {
  const NurserySearchException(
    super.message,
  );
}