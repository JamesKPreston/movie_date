class RoomOccupants {
  RoomOccupants({
    required this.id,
    required this.roomId,
    required this.profileId,
  });

  /// Id of the room occupants record
  final String id;

  /// Room Id of the room occupants record
  final String roomId;

  /// User Id of the room occupants record
  final String profileId;

  /// Converts a room occupants from a map to an object
  factory RoomOccupants.fromMap(Map<String, dynamic> map) {
    return RoomOccupants(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      profileId: map['profile_id'] as String,
    );
  }
}
