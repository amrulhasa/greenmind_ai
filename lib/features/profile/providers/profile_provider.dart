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
    Future.microtask(_loadProfile);

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
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to load profile.',
      );
    }
  }

  // ============================================================
  // UPDATE PROFILE INFORMATION
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
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      // User cancelled.
      if (pickedImage == null) {
        return;
      }

      // Read selected/captured image.
      final Uint8List bytes =
          await pickedImage.readAsBytes();

      // Keep old image path.
      final oldImagePath =
          state.profile.profileImagePath;

      // Save new image with a NEW filename.
      final String newImagePath =
          await _storageService.saveProfileImage(
        bytes,
      );

      // Create updated profile.
      final updatedProfile =
          state.profile.copyWith(
        profileImagePath: newImagePath,
      );

      // Save profile metadata.
      await _storageService.saveProfile(
        updatedProfile,
      );

      // IMPORTANT:
      // Immediately update Riverpod state.
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        errorMessage: null,
      );

      // Delete old image only after
      // new image has been successfully saved.
      if (oldImagePath != null &&
          oldImagePath.isNotEmpty &&
          oldImagePath != newImagePath) {
        await _storageService.deleteProfileImage(
          oldImagePath,
        );
      }
    } catch (_) {
      state = state.copyWith(
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
      final oldImagePath =
          state.profile.profileImagePath;

      // Remove image file.
      await _storageService.deleteProfileImage(
        oldImagePath,
      );

      // Remove image path from profile state.
      final updatedProfile =
          state.profile.copyWith(
        clearProfileImage: true,
      );

      // Save updated profile.
      await _storageService.saveProfile(
        updatedProfile,
      );

      // Immediately update UI.
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
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
      final oldImagePath =
          state.profile.profileImagePath;

      // Delete old image.
      await _storageService.deleteProfileImage(
        oldImagePath,
      );

      // Clear profile data.
      await _storageService.clearProfile();

      const defaultProfile = UserProfile();

      // Immediately reset state.
      state = state.copyWith(
        profile: defaultProfile,
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
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
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
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
  }) {
    return ProfileState(
      profile:
          profile ?? this.profile,
      isLoading:
          isLoading ?? this.isLoading,
      errorMessage:
          errorMessage,
    );
  }
}