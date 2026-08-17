import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final LocationService instance =
      LocationService._();

  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const Duration locationTimeout =
      Duration(seconds: 25);

  static const Duration webMaximumAge =
      Duration(seconds: 30);

  // ============================================================
  // LOCATION SERVICE ENABLED
  // ============================================================

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CHECK / REQUEST PERMISSION
  // ============================================================

  Future<LocationPermission> checkPermission({
    bool requestIfDenied = true,
  }) async {
    var permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied &&
        requestIfDenied) {
      permission =
          await Geolocator.requestPermission();
    }

    return permission;
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<Position> getCurrentLocation() async {
    // ----------------------------------------------------------
    // CHECK LOCATION SERVICE
    // ----------------------------------------------------------

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    // ----------------------------------------------------------
    // WEB
    // ----------------------------------------------------------

    // Browsers do not expose a traditional device GPS switch
    // through Geolocator in the same way as Android/iOS.
    //
    // Therefore, on web we primarily rely on the browser
    // permission dialog and WebSettings.
    if (!kIsWeb && !serviceEnabled) {
      throw const AppLocationServiceDisabledException();
    }

    // ----------------------------------------------------------
    // CHECK PERMISSION
    // ----------------------------------------------------------

    var permission =
        await Geolocator.checkPermission();

    // ----------------------------------------------------------
    // REQUEST PERMISSION
    // ----------------------------------------------------------

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    // ----------------------------------------------------------
    // DENIED
    // ----------------------------------------------------------

    if (permission == LocationPermission.denied) {
      throw const AppLocationPermissionDeniedException();
    }

    // ----------------------------------------------------------
    // DENIED FOREVER
    // ----------------------------------------------------------

    if (permission ==
        LocationPermission.deniedForever) {
      throw const AppLocationPermissionDeniedForeverException();
    }

    // ----------------------------------------------------------
    // LOCATION SETTINGS
    // ----------------------------------------------------------

    final LocationSettings settings;

    if (kIsWeb) {
      // IMPORTANT:
      // WebSettings is not a const constructor
      // in the current Geolocator version.
      settings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        maximumAge: webMaximumAge,
        timeLimit: locationTimeout,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: locationTimeout,
      );
    }

    // ----------------------------------------------------------
    // GET POSITION
    // ----------------------------------------------------------

    try {
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

      return position;
    } on TimeoutException {
      // --------------------------------------------------------
      // LAST KNOWN FALLBACK
      // --------------------------------------------------------

      final lastKnown =
          await getLastKnownLocation();

      if (lastKnown != null) {
        return lastKnown;
      }

      throw const LocationFetchException(
        'Getting your location took too long.',
      );
    } on LocationServiceDisabledException {
      throw const AppLocationServiceDisabledException();
    } on PermissionDeniedException {
      throw const AppLocationPermissionDeniedException();
    } catch (error) {
      final text =
          error.toString().toLowerCase();

      if (text.contains('permission')) {
        throw const AppLocationPermissionDeniedException();
      }

      if (text.contains('disabled')) {
        throw const AppLocationServiceDisabledException();
      }

      throw LocationFetchException(
        error.toString(),
      );
    }
  }

  // ============================================================
  // GET LAST KNOWN LOCATION
  // ============================================================

  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // OPEN LOCATION SETTINGS
  // ============================================================

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // DISTANCE
  // ============================================================

  double distanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // ============================================================
  // DISTANCE LABEL
  // ============================================================

  String distanceLabel({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distance =
        distanceInMeters(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    final kilometers =
        distance / 1000;

    return '${kilometers.toStringAsFixed(
      kilometers < 10 ? 1 : 0,
    )} km';
  }
}

// ============================================================
// EXCEPTIONS
// ============================================================

class AppLocationServiceDisabledException
    implements Exception {
  const AppLocationServiceDisabledException();

  @override
  String toString() {
    return 'Location service is disabled.';
  }
}

class AppLocationPermissionDeniedException
    implements Exception {
  const AppLocationPermissionDeniedException();

  @override
  String toString() {
    return 'Location permission was denied.';
  }
}

class AppLocationPermissionDeniedForeverException
    implements Exception {
  const AppLocationPermissionDeniedForeverException();

  @override
  String toString() {
    return 'Location permission was permanently denied.';
  }
}

class LocationFetchException
    implements Exception {
  final String message;

  const LocationFetchException(
    this.message,
  );

  @override
  String toString() {
    return message;
  }
}