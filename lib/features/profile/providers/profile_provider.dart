import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/profile_storage_service.dart';

// ============================================================================
// STORAGE
// ============================================================================

final profileStorageServiceProvider =
    Provider<ProfileStorageService>((ref) {
  return ProfileStorageService();
});

// ============================================================================
// PROFILE PROVIDER
// ============================================================================

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

// ============================================================================
// PROFILE NOTIFIER
// ============================================================================

class ProfileNotifier extends Notifier<ProfileState> {
  ProfileStorageService get _storage =>
      ref.read(profileStorageServiceProvider);

  FirebaseAuth get _auth =>
      FirebaseAuth.instance;

  StreamSubscription<User?>? _authSubscription;

  Future<void> _saveQueue =
      Future<void>.value();

  int _operationVersion = 0;

  UserProfile? _pendingProfile;

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  ProfileState build() {
    _listenToAuthChanges();

    ref.onDispose(() {
      _authSubscription?.cancel();
      _authSubscription = null;
    });

    return const ProfileState(
      isLoading: true,
    );
  }

  // ==========================================================================
  // AUTH LISTENER
  // ==========================================================================

  void _listenToAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription =
        _auth.authStateChanges().listen(
      (user) async {
        if (user == null) {
          _pendingProfile = null;

          state = const ProfileState(
            profile: UserProfile(),
            isLoading: false,
          );

          return;
        }

        await _loadProfile(user);
      },
      onError: (error, stackTrace) {
        debugPrint(
          'AUTH STATE ERROR: $error',
        );

        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Unable to restore account session.',
        );
      },
    );
  }

  // ==========================================================================
  // LOAD PROFILE
  // ==========================================================================

  Future<void> _loadProfile(
    User user,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final loadedProfile =
          await _storage.loadProfile(
        userId: user.uid,
      );

      final effectiveProfile =
          _pendingProfile ?? loadedProfile;

      final profile =
          effectiveProfile.copyWith(
        email: user.email ??
            effectiveProfile.email,
      );

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );

      debugPrint(
        'PROFILE LOADED | '
        'darkMode=${profile.darkModeEnabled}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE LOAD ERROR: $e',
      );

      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load profile.',
      );
    }
  }

  // ==========================================================================
  // RELOAD
  // ==========================================================================

  Future<void> reloadProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _loadProfile(user);
  }

  // ==========================================================================
  // UPDATE PROFILE
  // ==========================================================================

  Future<void> updateProfile({
    String? name,
    String? location,
    String? phone,
    String? bio,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    final updated =
        state.profile.copyWith(
      name: name,
      location: location,
      phone: phone,
      bio: bio,
    );

    await _saveProfile(
      oldProfile: state.profile,
      updatedProfile: updated,
      userId: user.uid,
    );
  }

  // ==========================================================================
  // TOGGLE NOTIFICATIONS
  // ==========================================================================

  Future<void> toggleNotifications() async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    final oldProfile =
        state.profile;

    final updated =
        oldProfile.copyWith(
      notificationsEnabled:
          !oldProfile.notificationsEnabled,
    );

    await _savePreference(
      oldProfile: oldProfile,
      updatedProfile: updated,
      userId: user.uid,
    );
  }

  // ==========================================================================
  // TOGGLE DARK MODE
  // ==========================================================================

  Future<void> toggleDarkMode() async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    final oldProfile =
        state.profile;

    final updated =
        oldProfile.copyWith(
      darkModeEnabled:
          !oldProfile.darkModeEnabled,
    );

    // Immediate UI update.
    state = state.copyWith(
      profile: updated,
      clearError: true,
    );

    // Keep pending state so profile loading cannot
    // overwrite the new preference.
    _pendingProfile = updated;

    debugPrint(
      'DARK MODE → '
      '${updated.darkModeEnabled}',
    );

    await _queueSave(
      oldProfile: oldProfile,
      updatedProfile: updated,
      userId: user.uid,
    );
  }

  // ==========================================================================
  // SAVE PREFERENCE
  // ==========================================================================

  Future<void> _savePreference({
    required UserProfile oldProfile,
    required UserProfile updatedProfile,
    required String userId,
  }) async {
    state = state.copyWith(
      profile: updatedProfile,
      clearError: true,
    );

    _pendingProfile = updatedProfile;

    await _queueSave(
      oldProfile: oldProfile,
      updatedProfile: updatedProfile,
      userId: userId,
    );
  }

  // ==========================================================================
  // QUEUED SAVE
  // ==========================================================================

  Future<void> _queueSave({
    required UserProfile oldProfile,
    required UserProfile updatedProfile,
    required String userId,
  }) async {
    final operation =
        ++_operationVersion;

    _saveQueue = _saveQueue.then(
      (_) async {
        try {
          await _storage.saveProfile(
            userId: userId,
            profile: updatedProfile,
          );

          if (operation ==
              _operationVersion) {
            _pendingProfile = null;

            state = state.copyWith(
              profile: updatedProfile,
              clearError: true,
            );

            debugPrint(
              'PROFILE SAVED SUCCESSFULLY',
            );
          }
        } catch (e, stackTrace) {
          debugPrint(
            'PROFILE SAVE ERROR: $e',
          );

          debugPrint('$stackTrace');

          if (operation ==
              _operationVersion) {
            _pendingProfile = null;

            state = state.copyWith(
              profile: oldProfile,
              errorMessage:
                  'Unable to save your preference.',
            );
          }
        }
      },
    );

    await _saveQueue;
  }

  // ==========================================================================
  // NORMAL PROFILE SAVE
  // ==========================================================================

  Future<void> _saveProfile({
    required UserProfile oldProfile,
    required UserProfile updatedProfile,
    required String userId,
  }) async {
    final operation =
        ++_operationVersion;

    _pendingProfile = updatedProfile;

    state = state.copyWith(
      profile: updatedProfile,
      clearError: true,
    );

    try {
      await _storage.saveProfile(
        userId: userId,
        profile: updatedProfile,
      );

      if (operation ==
          _operationVersion) {
        _pendingProfile = null;

        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          clearError: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE SAVE ERROR: $e',
      );

      debugPrint('$stackTrace');

      if (operation ==
          _operationVersion) {
        _pendingProfile = null;

        state = state.copyWith(
          profile: oldProfile,
          isLoading: false,
          errorMessage:
              'Unable to save profile.',
        );
      }
    }
  }

  // ==========================================================================
  // CHANGE PROFILE IMAGE
  // ==========================================================================

  Future<void> changeProfilePicture({
    required ImageSource source,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final picker = ImagePicker();

      final image =
          await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        state = state.copyWith(
          isLoading: false,
        );
        return;
      }

      final bytes =
          await image.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Selected image is empty.',
        );
      }

      final imageBase64 =
          await _storage.saveProfileImage(
        bytes,
      );

      if (imageBase64.isEmpty) {
        throw Exception(
          'Unable to process image.',
        );
      }

      final updated =
          state.profile.copyWith(
        profileImagePath:
            imageBase64,
      );

      await _storage.saveProfile(
        userId: user.uid,
        profile: updated,
      );

      state = state.copyWith(
        profile: updated,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PROFILE IMAGE ERROR: $e',
      );

      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to change profile picture.',
      );
    }
  }

  // ==========================================================================
  // REMOVE PROFILE IMAGE
  // ==========================================================================

  Future<void> removeProfilePicture() async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final updated =
          state.profile.copyWith(
        clearProfileImage: true,
      );

      await _storage.saveProfile(
        userId: user.uid,
        profile: updated,
      );

      state = state.copyWith(
        profile: updated,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'REMOVE IMAGE ERROR: $e',
      );

      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to remove profile picture.',
      );
    }
  }

  // ==========================================================================
  // RESET PROFILE
  // ==========================================================================

  Future<void> resetProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      _setLoginError();
      return;
    }

    try {
      ++_operationVersion;

      _pendingProfile = null;

      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      await _storage.resetProfile(
        userId: user.uid,
      );

      final profile =
          UserProfile(
        name: 'Plant Lover',
        email: user.email ?? '',
        bio: 'GreenMind AI plant enthusiast',
        notificationsEnabled: true,
        darkModeEnabled: false,
      );

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'RESET PROFILE ERROR: $e',
      );

      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to reset profile.',
      );
    }
  }

  Future<void> resetProfileData() =>
      resetProfile();

  // ==========================================================================
  // LOGIN ERROR
  // ==========================================================================

  void _setLoginError() {
    state = state.copyWith(
      errorMessage:
          'Please login first.',
    );
  }
}

// ============================================================================
// PROFILE STATE
// ============================================================================

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