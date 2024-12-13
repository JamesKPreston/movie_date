class Profile {
  Profile(
    this.roomId, {
    required this.id,
    required this.room_code,
    required this.createdAt,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String room_code;

  /// Date and time when the profile was created
  final DateTime createdAt;

  /// Room Id of the room occupants record
  String roomId;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        room_code = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        roomId = map['room_id'];
}
