import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class ProfileStorageService {
  static const String _storageKey = 'user_profile';

  Future<UserProfile> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return const UserProfile();
    }

    final decodedData = jsonDecode(storedData);

    return _fromJson(
      Map<String, dynamic>.from(decodedData as Map),
    );
  }

  Future<void> saveProfile(
    UserProfile profile,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      _toJson(profile),
    );

    await preferences.setString(
      _storageKey,
      encodedData,
    );
  }

  Future<void> clearProfile() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  Map<String, dynamic> _toJson(
    UserProfile profile,
  ) {
    return {
      'name': profile.name,
      'email': profile.email,
      'location': profile.location,
      'bio': profile.bio,
      'notificationsEnabled':
          profile.notificationsEnabled,
      'darkModeEnabled':
          profile.darkModeEnabled,
    };
  }

  UserProfile _fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      name: json['name'] as String? ?? 'Plant Lover',
      email: json['email'] as String? ?? 'user@example.com',
      location: json['location'] as String? ?? '',
      bio: json['bio'] as String? ??
          'GreenMind AI plant enthusiast',
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled:
          json['darkModeEnabled'] as bool? ?? false,
    );
  }
}