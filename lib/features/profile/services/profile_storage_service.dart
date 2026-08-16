import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
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

    if (storedData == null ||
        storedData.isEmpty) {
      return const UserProfile();
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is! Map) {
        return const UserProfile();
      }

      return _fromJson(
        Map<String, dynamic>.from(decoded),
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

    final encoded = jsonEncode(
      _toJson(profile),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }

  // ============================================================
  // SAVE PROFILE IMAGE
  // ============================================================
  //
  // The image is:
  // 1. Decoded
  // 2. Resized
  // 3. Compressed
  // 4. Converted to Base64
  //
  // No dart:io.
  // No File.
  // No path_provider.
  //
  // Therefore this works on:
  // Android
  // Windows
  // Chrome/Web
  // ============================================================

  Future<String> saveProfileImage(
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty) {
      throw Exception(
        'Profile image is empty.',
      );
    }

    final decodedImage =
        img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception(
        'Unable to process profile image.',
      );
    }

    // Keep the image reasonably small
    // for SharedPreferences storage.
    final resizedImage =
        decodedImage.width > 700
            ? img.copyResize(
                decodedImage,
                width: 700,
              )
            : decodedImage;

    final compressedBytes =
        img.encodeJpg(
      resizedImage,
      quality: 75,
    );

    if (compressedBytes.isEmpty) {
      throw Exception(
        'Unable to compress profile image.',
      );
    }

    return base64Encode(
      compressedBytes,
    );
  }

  // ============================================================
  // DELETE PROFILE IMAGE
  // ============================================================
  //
  // There is no physical file.
  // The image is stored inside profile JSON.
  //
  // Removing profileImagePath from UserProfile
  // effectively removes the image.
  // ============================================================

  Future<void> deleteProfileImage(
    String? imageBase64,
  ) async {
    // Nothing to delete physically.
  }

  // ============================================================
  // CHECK PROFILE IMAGE
  // ============================================================

  Future<bool> profileImageExists(
    String? imageBase64,
  ) async {
    return imageBase64 != null &&
        imageBase64.isNotEmpty;
  }

  // ============================================================
  // CLEAR PROFILE
  // ============================================================

  Future<void> clearProfile() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      _storageKey,
    );
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
      name:
          json['name'] as String? ??
              'Plant Lover',

      email:
          json['email'] as String? ??
              'user@example.com',

      location:
          json['location'] as String? ??
              '',

      bio:
          json['bio'] as String? ??
              'GreenMind AI plant enthusiast',

      profileImagePath:
          json['profileImagePath']
              as String?,

      notificationsEnabled:
          json['notificationsEnabled']
                  as bool? ??
              true,

      darkModeEnabled:
          json['darkModeEnabled']
                  as bool? ??
              false,
    );
  }
}