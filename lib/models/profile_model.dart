class Profile {
  Profile({
    required this.id,
    required this.createdAt,
    required this.email,
    required this.avatarUrl,
    required this.displayName,
  });

  /// User ID of the profile
  final String id;

  /// Date and time when the profile was created
  final DateTime createdAt;

  final String avatarUrl;
  final String displayName;

  final String email;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']),
        email = map['email'],
        avatarUrl = map['avatar_url'] ?? '',
        displayName = map['display_name'] ?? map['email'];
}
