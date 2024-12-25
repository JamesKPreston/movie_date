class Member {
  Member({
    required this.id,
    required this.room_id,
    required this.user_id,
    required this.email,
  });

  final String id;

  final String room_id;

  final String user_id;

  final String email;

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as String,
      room_id: map['room_id'] as String,
      user_id: map['user_id'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': room_id,
      'user_id': user_id,
      'email': email,
    };
  }
}
