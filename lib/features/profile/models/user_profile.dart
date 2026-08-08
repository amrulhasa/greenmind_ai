class UserProfile {
  final String name;
  final String email;
  final String location;
  final String bio;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const UserProfile({
    this.name = 'Plant Lover',
    this.email = 'user@example.com',
    this.location = '',
    this.bio = 'GreenMind AI plant enthusiast',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? location,
    String? bio,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled:
          darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}