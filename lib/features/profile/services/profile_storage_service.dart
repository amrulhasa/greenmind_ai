import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileStorageService {
  static const String _storageKey = 'user_profile';

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<UserProfile> loadProfile() async {
    final preferences =
        await SharedPreferences.getInstance();

    final storedData =
        preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return const UserProfile();
    }

    try {
      final decodedData = jsonDecode(storedData);

      return _fromJson(
        Map<String, dynamic>.from(
          decodedData as Map,
        ),
      );
    } catch (_) {
      return const UserProfile();
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> saveProfile(
    UserProfile profile,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      _toJson(profile),
    );

    await preferences.setString(
      _storageKey,
      encodedData,
    );
  }

  // ============================================================
  // SAVE PROFILE IMAGE
  // ============================================================

  Future<String> saveProfileImage(
    Uint8List bytes,
  ) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final file = File(
      '${directory.path}/profile_image_$timestamp.jpg',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file.path;
  }

  // ============================================================
  // DELETE PROFILE IMAGE
  // ============================================================

  Future<void> deleteProfileImage(
    String? imagePath,
  ) async {
    if (imagePath == null ||
        imagePath.isEmpty) {
      return;
    }

    try {
      final file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore file deletion errors.
    }
  }

  // ============================================================
  // CHECK PROFILE IMAGE
  // ============================================================

  Future<bool> profileImageExists(
    String? imagePath,
  ) async {
    if (imagePath == null ||
        imagePath.isEmpty) {
      return false;
    }

    final file = File(imagePath);

    return file.exists();
  }

  // ============================================================
  // CLEAR PROFILE
  // ============================================================

  Future<void> clearProfile() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  // ============================================================
  // PROFILE → JSON
  // ============================================================

  Map<String, dynamic> _toJson(
    UserProfile profile,
  ) {
    return {
      'name': profile.name,
      'email': profile.email,
      'location': profile.location,
      'bio': profile.bio,
      'profileImagePath':
          profile.profileImagePath,
      'notificationsEnabled':
          profile.notificationsEnabled,
      'darkModeEnabled':
          profile.darkModeEnabled,
    };
  }

  // ============================================================
  // JSON → PROFILE
  // ============================================================

  UserProfile _fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      name: json['name'] as String? ??
          'Plant Lover',

      email: json['email'] as String? ??
          'user@example.com',

      location: json['location'] as String? ??
          '',

      bio: json['bio'] as String? ??
          'GreenMind AI plant enthusiast',

      profileImagePath:
          json['profileImagePath'] as String?,

      notificationsEnabled:
          json['notificationsEnabled'] as bool? ??
              true,

      darkModeEnabled:
          json['darkModeEnabled'] as bool? ??
              false,
    );
  }
}