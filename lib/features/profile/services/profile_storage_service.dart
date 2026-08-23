import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

import '../models/user_profile.dart';

class ProfileStorageService {
  ProfileStorageService();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  // ==========================================================================
  // CURRENT USER
  // ==========================================================================

  User? get currentUser {
    return _auth.currentUser;
  }

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ==========================================================================
  // LOAD PROFILE
  // ==========================================================================

  Future<UserProfile> loadProfile({
    required String userId,
  }) async {
    _validateUser(userId);

    try {
      final document =
          await _usersCollection
              .doc(userId)
              .get()
              .timeout(
                const Duration(seconds: 15),
              );

      // ----------------------------------------------------------------------
      // PROFILE DOES NOT EXIST
      // ----------------------------------------------------------------------

      if (!document.exists) {
        final user = _auth.currentUser;

        final profile = UserProfile(
          name: _defaultName(user),
          email: user?.email ?? '',
        );

        await saveProfile(
          userId: userId,
          profile: profile,
          createIfMissing: true,
        );

        return profile;
      }

      // ----------------------------------------------------------------------
      // PROFILE DATA
      // ----------------------------------------------------------------------

      final data = document.data();

      if (data == null) {
        return UserProfile(
          email: _auth.currentUser?.email ?? '',
        );
      }

      final profileData =
          Map<String, dynamic>.from(data);

      // Firebase Auth owns email.
      final authEmail =
          _auth.currentUser?.email ?? '';

      if (authEmail.isNotEmpty) {
        profileData['email'] = authEmail;
      }

      return UserProfile.fromJson(
        profileData,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to load profile: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(
        'Unable to load profile: $e',
      );
    }
  }

  // ==========================================================================
  // SAVE PROFILE
  // ==========================================================================

  Future<void> saveProfile({
    required String userId,
    required UserProfile profile,
    bool createIfMissing = false,
  }) async {
    _validateUser(userId);

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception(
          'No authenticated user found.',
        );
      }

      final email =
          user.email ?? profile.email;

      final data =
          <String, dynamic>{
        'name':
            profile.name.trim(),

        'email':
            email,

        'location':
            profile.location.trim(),

        'phone':
            profile.phone.trim(),

        'bio':
            profile.bio.trim(),

        'profileImagePath':
            profile.profileImagePath,

        'notificationsEnabled':
            profile.notificationsEnabled,

        'darkModeEnabled':
            profile.darkModeEnabled,

        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      // ----------------------------------------------------------------------
      // CREATE ONLY FIELDS
      // ----------------------------------------------------------------------

      if (createIfMissing) {
        data['createdAt'] =
            FieldValue.serverTimestamp();

        data['role'] = 'user';
      }

      await _usersCollection
          .doc(userId)
          .set(
            data,
            SetOptions(
              merge: true,
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to save profile: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(
        'Unable to save profile: $e',
      );
    }
  }

  // ==========================================================================
  // ENSURE PROFILE
  // ==========================================================================

  Future<UserProfile> ensureProfile({
    required User user,
  }) async {
    _validateUser(user.uid);

    try {
      final document =
          await _usersCollection
              .doc(user.uid)
              .get()
              .timeout(
                const Duration(seconds: 15),
              );

      if (document.exists) {
        return loadProfile(
          userId: user.uid,
        );
      }

      final profile = UserProfile(
        name: _defaultName(user),
        email: user.email ?? '',
      );

      await saveProfile(
        userId: user.uid,
        profile: profile,
        createIfMissing: true,
      );

      return profile;
    } catch (e) {
      throw Exception(
        'Unable to initialize profile: $e',
      );
    }
  }

  // ==========================================================================
  // PROFILE IMAGE
  // ==========================================================================

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

    final resizedImage =
        decodedImage.width > 600
            ? img.copyResize(
                decodedImage,
                width: 600,
              )
            : decodedImage;

    final compressedBytes =
        img.encodeJpg(
      resizedImage,
      quality: 70,
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

  // ==========================================================================
  // DELETE PROFILE IMAGE
  // ==========================================================================

  Future<void> deleteProfileImage(
    String? imageBase64,
  ) async {
    // Profile image is stored inside profileImagePath.
    // Setting profileImagePath to null removes it.
  }

  // ==========================================================================
  // PROFILE IMAGE EXISTS
  // ==========================================================================

  Future<bool> profileImageExists(
    String? imageBase64,
  ) async {
    return imageBase64 != null &&
        imageBase64.isNotEmpty;
  }

  // ==========================================================================
  // RESET PROFILE
  // ==========================================================================

  Future<void> resetProfile({
    required String userId,
  }) async {
    _validateUser(userId);

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception(
          'No authenticated user found.',
        );
      }

      await _usersCollection
          .doc(userId)
          .set(
            {
              'name':
                  _defaultName(user),

              'email':
                  user.email ?? '',

              'location':
                  '',

              'phone':
                  '',

              'bio':
                  'GreenMind AI plant enthusiast',

              'profileImagePath':
                  null,

              'notificationsEnabled':
                  true,

              'darkModeEnabled':
                  false,

              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
            SetOptions(
              merge: true,
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to reset profile: '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception(
        'Unable to reset profile: $e',
      );
    }
  }

  // ==========================================================================
  // LEGACY
  // ==========================================================================

  Future<void> clearProfile({
    required String userId,
  }) async {
    await resetProfile(
      userId: userId,
    );
  }

  // ==========================================================================
  // VALIDATE USER
  // ==========================================================================

  void _validateUser(
    String userId,
  ) {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    if (user.uid != userId) {
      throw Exception(
        'Unauthorized profile operation.',
      );
    }
  }

  // ==========================================================================
  // DEFAULT NAME
  // ==========================================================================

  String _defaultName(
    User? user,
  ) {
    if (user == null) {
      return 'Plant Lover';
    }

    final displayName =
        user.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty) {
      return displayName;
    }

    final email =
        user.email?.trim();

    if (email != null &&
        email.isNotEmpty) {
      final username =
          email.split('@').first.trim();

      if (username.isNotEmpty) {
        return username;
      }
    }

    return 'Plant Lover';
  }
}