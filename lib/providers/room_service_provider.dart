import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/services/room_service.dart';

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});
