import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/profile_storage_service.dart';

final profileStorageServiceProvider =
    Provider<ProfileStorageService>(
  (ref) => ProfileStorageService(),
);

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<ProfileState> {
  ProfileStorageService get _storageService {
    return ref.read(
      profileStorageServiceProvider,
    );
  }

  @override
  ProfileState build() {
    Future.microtask(
      _loadProfile,
    );

    return const ProfileState(
      isLoading: true,
    );
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profile =
          await _storageService.loadProfile();

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load profile.',
      );
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> updateProfile({
    String? name,
    String? email,
    String? location,
    String? bio,
  }) async {
    final updatedProfile =
        state.profile.copyWith(
      name: name,
      email: email,
      location: location,
      bio: bio,
    );

    await _saveProfile(
      updatedProfile,
    );
  }

  // ============================================================
  // CHANGE PROFILE PICTURE
  // ============================================================

  Future<void> changeProfilePicture({
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();

      final XFile? pickedImage =
          await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      // User cancelled image selection.
      if (pickedImage == null) {
        return;
      }

      // Read image as bytes.
      final Uint8List bytes =
          await pickedImage.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'Selected image is empty.',
        );
      }

      // Compress image and convert to Base64.
      //
      // This is cross-platform:
      // Android + Windows + Web.
      final String imageBase64 =
          await _storageService.saveProfileImage(
        bytes,
      );

      if (imageBase64.isEmpty) {
        throw Exception(
          'Unable to process profile image.',
        );
      }

      // Save Base64 image inside profile.
      final updatedProfile =
          state.profile.copyWith(
        profileImagePath:
            imageBase64,
      );

      await _storageService.saveProfile(
        updatedProfile,
      );

      // Update UI immediately.
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
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
    try {
      final updatedProfile =
          state.profile.copyWith(
        clearProfileImage: true,
      );

      await _storageService.saveProfile(
        updatedProfile,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
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
    final updatedProfile =
        state.profile.copyWith(
      notificationsEnabled:
          !state.profile.notificationsEnabled,
    );

    await _saveProfile(
      updatedProfile,
    );
  }

  // ============================================================
  // TOGGLE DARK MODE
  // ============================================================

  Future<void> toggleDarkMode() async {
    final updatedProfile =
        state.profile.copyWith(
      darkModeEnabled:
          !state.profile.darkModeEnabled,
    );

    await _saveProfile(
      updatedProfile,
    );
  }

  // ============================================================
  // RESET PROFILE
  // ============================================================

  Future<void> resetProfile() async {
    try {
      await _storageService.clearProfile();

      const defaultProfile =
          UserProfile();

      state = state.copyWith(
        profile: defaultProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to reset profile.',
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile(
    UserProfile profile,
  ) async {
    try {
      await _storageService.saveProfile(
        profile,
      );

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
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
    this.profile = const UserProfile(),
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