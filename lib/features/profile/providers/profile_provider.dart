import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return ref.read(profileStorageServiceProvider);
  }

  @override
  ProfileState build() {
    Future.microtask(_loadProfile);

    return const ProfileState(
      isLoading: true,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _storageService.loadProfile();

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load profile.',
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? location,
    String? bio,
  }) async {
    final updatedProfile = state.profile.copyWith(
      name: name,
      email: email,
      location: location,
      bio: bio,
    );

    await _saveProfile(updatedProfile);
  }

  Future<void> toggleNotifications() async {
    final updatedProfile = state.profile.copyWith(
      notificationsEnabled:
          !state.profile.notificationsEnabled,
    );

    await _saveProfile(updatedProfile);
  }

  Future<void> toggleDarkMode() async {
    final updatedProfile = state.profile.copyWith(
      darkModeEnabled:
          !state.profile.darkModeEnabled,
    );

    await _saveProfile(updatedProfile);
  }

  Future<void> resetProfile() async {
    const defaultProfile = UserProfile();

    await _storageService.saveProfile(
      defaultProfile,
    );

    state = state.copyWith(
      profile: defaultProfile,
      errorMessage: null,
    );
  }

  Future<void> _saveProfile(
    UserProfile profile,
  ) async {
    try {
      await _storageService.saveProfile(profile);

      state = state.copyWith(
        profile: profile,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to save profile.',
      );
    }
  }
}

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
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}