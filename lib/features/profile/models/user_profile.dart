class UserProfile {
  final String name;
  final String email;
  final String location;
  final String phone;
  final String bio;
  final String? profileImagePath;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const UserProfile({
    this.name = 'Plant Lover',
    this.email = '',
    this.location = '',
    this.phone = '',
    this.bio = 'GreenMind AI plant enthusiast',
    this.profileImagePath,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? location,
    String? phone,
    String? bio,
    String? profileImagePath,
    bool clearProfileImage = false,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImagePath: clearProfileImage
          ? null
          : profileImagePath ?? this.profileImagePath,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled:
          darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'phone': phone,
      'bio': bio,
      'profileImagePath': profileImagePath,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    final name =
        json['name']?.toString().trim() ?? '';

    final email =
        json['email']?.toString().trim() ?? '';

    final location =
        json['location']?.toString().trim() ?? '';

    final phone =
        json['phone']?.toString().trim() ?? '';

    final bio =
        json['bio']?.toString().trim() ?? '';

    final profileImage =
        json['profileImagePath']?.toString();

    final notifications =
        json['notificationsEnabled'];

    final darkMode =
        json['darkModeEnabled'];

    return UserProfile(
      name: name.isNotEmpty
          ? name
          : 'Plant Lover',
      email: email,
      location: location,
      phone: phone,
      bio: bio.isNotEmpty
          ? bio
          : 'GreenMind AI plant enthusiast',
      profileImagePath:
          profileImage != null &&
                  profileImage.trim().isNotEmpty
              ? profileImage
              : null,
      notificationsEnabled:
          notifications is bool
              ? notifications
              : true,
      darkModeEnabled:
          darkMode is bool
              ? darkMode
              : false,
    );
  }
}