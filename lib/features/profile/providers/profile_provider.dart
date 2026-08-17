import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/profile_storage_service.dart';

// ============================================================
// PROFILE STORAGE SERVICE PROVIDER
// ============================================================

final profileStorageServiceProvider =
    Provider<ProfileStorageService>(
  (ref) {
    return ProfileStorageService();
  },
);

// ============================================================
// PROFILE PROVIDER
// ============================================================

final profileProvider =
    NotifierProvider<
        ProfileNotifier,
        ProfileState>(
  ProfileNotifier.new,
);

// ============================================================
// PROFILE NOTIFIER
// ============================================================

class ProfileNotifier
    extends Notifier<ProfileState> {
  // ============================================================
  // STORAGE SERVICE
  // ============================================================

  ProfileStorageService get _storageService {
    return ref.read(
      profileStorageServiceProvider,
    );
  }

  // ============================================================
  // FIREBASE AUTH
  // ============================================================

  FirebaseAuth get _auth {
    return FirebaseAuth.instance;
  }

  // ============================================================
  // AUTH LISTENER
  // ============================================================

  StreamSubscription<User?>? _authSubscription;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  ProfileState build() {
    // ----------------------------------------------------------
    // IMPORTANT
    //
    // Firebase Auth may need a short time to restore the
    // previously logged-in user after app restart.
    //
    // Therefore we DO NOT immediately assume that
    // currentUser == null means logged out.
    // ----------------------------------------------------------

    _listenToAuthChanges();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const ProfileState(
      isLoading: true,
    );
  }

  // ============================================================
  // LISTEN TO FIREBASE AUTH
  // ============================================================

  void _listenToAuthChanges() {
    _authSubscription =
        _auth.authStateChanges().listen(
      (User? user) async {
        if (user == null) {
          // ----------------------------------------------------
          // User is genuinely logged out.
          // ----------------------------------------------------

          state = const ProfileState(
            profile: UserProfile(),
            isLoading: false,
          );

          return;
        }

        // ------------------------------------------------------
        // Firebase has restored the logged-in user.
        // Now load profile from Firestore.
        // ------------------------------------------------------

        await _loadProfileForUser(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'AUTH STATE ERROR: $error',
        );

        debugPrint(
          '$stackTrace',
        );

        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Unable to restore account session.',
        );
      },
    );
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  // ignore: unused_element
  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    // ----------------------------------------------------------
    // If Firebase Auth has not restored the user yet,
    // DO NOT reset the profile.
    //
    // The authStateChanges listener will load it once
    // Firebase finishes restoring the session.
    // ----------------------------------------------------------

    if (user == null) {
      state = state.copyWith(
        isLoading: true,
      );

      return;
    }

    await _loadProfileForUser(user);
  }

  // ============================================================
  // LOAD PROFILE FOR USER
  // ============================================================

  Future<void> _loadProfileForUser(
    User user,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final profile =
          await _storageService.loadProfile(
        userId: user.uid,
      );

      // --------------------------------------------------------
      // Firebase Auth email is always authoritative.
      // --------------------------------------------------------

      final profileWithEmail =
          profile.copyWith(
        email: user.email ?? profile.email,
      );

      state = state.copyWith(
        profile: profileWithEmail,
        isLoading: false,
        clearError: true,
      );

      debugPrint(
        'PROFILE LOADED SUCCESSFULLY',
      );

      debugPrint(
        'UID: ${user.uid}',
      );

      debugPrint(
        'NAME: ${profileWithEmail.name}',
      );

      debugPrint(
        'EMAIL: ${profileWithEmail.email}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE LOAD ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load profile.',
      );
    }
  }

  // ============================================================
  // PUBLIC RELOAD
  // ============================================================

  Future<void> reloadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        isLoading: true,
      );

      return;
    }

    await _loadProfileForUser(user);
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> updateProfile({
    String? name,
    String? location,
    String? phone,
    String? bio,
  }) async {
    final user = _auth.currentUser;

    // ----------------------------------------------------------
    // AUTH CHECK
    // ----------------------------------------------------------

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    // ----------------------------------------------------------
    // CREATE UPDATED PROFILE
    // ----------------------------------------------------------

    final updatedProfile =
        state.profile.copyWith(
      name: name,
      location: location,
      phone: phone,
      bio: bio,

      // Email intentionally not changed.
      // Firebase Auth owns the account email.
    );

    // ----------------------------------------------------------
    // SAVE
    // ----------------------------------------------------------

    await _saveProfile(
      updatedProfile,
      user.uid,
    );
  }

  // ============================================================
  // CHANGE PROFILE PICTURE
  // ============================================================

  Future<void> changeProfilePicture({
    required ImageSource source,
  }) async {
    final user = _auth.currentUser;

    // ----------------------------------------------------------
    // AUTH CHECK
    // ----------------------------------------------------------

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    try {
      // --------------------------------------------------------
      // PICK IMAGE
      // --------------------------------------------------------

      final picker =
          ImagePicker();

      final XFile? pickedImage =
          await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      // User cancelled.
      if (pickedImage == null) {
        return;
      }

      // --------------------------------------------------------
      // READ IMAGE
      // --------------------------------------------------------

      final bytes =
          await pickedImage.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Selected image is empty.',
        );
      }

      // --------------------------------------------------------
      // COMPRESS + BASE64
      // --------------------------------------------------------

      final imageBase64 =
          await _storageService
              .saveProfileImage(
        bytes,
      );

      if (imageBase64.isEmpty) {
        throw Exception(
          'Unable to process profile image.',
        );
      }

      // --------------------------------------------------------
      // UPDATE PROFILE
      // --------------------------------------------------------

      final updatedProfile =
          state.profile.copyWith(
        profileImagePath:
            imageBase64,
      );

      // --------------------------------------------------------
      // SAVE TO FIRESTORE
      // --------------------------------------------------------

      await _storageService.saveProfile(
        userId: user.uid,
        profile: updatedProfile,
      );

      // --------------------------------------------------------
      // UPDATE UI
      // --------------------------------------------------------

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE IMAGE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to change profile picture.',
      );
    }
  }

  // ============================================================
  // REMOVE PROFILE PICTURE
  // ============================================================

  Future<void> removeProfilePicture() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    try {
      final updatedProfile =
          state.profile.copyWith(
        clearProfileImage: true,
      );

      await _storageService.saveProfile(
        userId: user.uid,
        profile: updatedProfile,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'REMOVE PROFILE IMAGE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to remove profile picture.',
      );
    }
  }

  // ============================================================
  // TOGGLE NOTIFICATIONS
  // ============================================================

  Future<void> toggleNotifications() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    final updatedProfile =
        state.profile.copyWith(
      notificationsEnabled:
          !state.profile.notificationsEnabled,
    );

    await _saveProfile(
      updatedProfile,
      user.uid,
    );
  }

  // ============================================================
  // TOGGLE DARK MODE
  // ============================================================

  Future<void> toggleDarkMode() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    final updatedProfile =
        state.profile.copyWith(
      darkModeEnabled:
          !state.profile.darkModeEnabled,
    );

    await _saveProfile(
      updatedProfile,
      user.uid,
    );
  }

  // ============================================================
  // RESET PROFILE
  // ============================================================
  //
  // This is a REAL profile reset.
  //
  // It does NOT:
  // - logout user
  // - delete Firebase account
  // - delete recent plants
  //
  // ============================================================

  Future<void> resetProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      state = state.copyWith(
        errorMessage:
            'Please login first.',
      );

      return;
    }

    try {
      await _storageService.resetProfile(
        userId: user.uid,
      );

      final defaultProfile =
          UserProfile(
        email: user.email ?? '',
      );

      state = state.copyWith(
        profile: defaultProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RESET PROFILE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to reset profile.',
      );
    }
  }

  // ============================================================
  // RESET PROFILE DATA
  // ============================================================
  //
  // Kept because ProfileScreen uses this method.
  //
  // ============================================================

  Future<void> resetProfileData() async {
    await resetProfile();
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile(
    UserProfile profile,
    String userId,
  ) async {
    try {
      // --------------------------------------------------------
      // SAVE TO FIRESTORE
      // --------------------------------------------------------

      await _storageService.saveProfile(
        userId: userId,
        profile: profile,
      );

      // --------------------------------------------------------
      // UPDATE LOCAL RIVERPOD STATE
      // --------------------------------------------------------

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );

      debugPrint(
        'PROFILE SAVED SUCCESSFULLY',
      );

      debugPrint(
        'UID: $userId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE SAVE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to save profile.',
      );
    }
  }
}

// ============================================================
// PROFILE STATE
// ============================================================

class ProfileState {
  final UserProfile profile;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profile =
        const UserProfile(),
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      profile:
          profile ?? this.profile,

      isLoading:
          isLoading ?? this.isLoading,

      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}