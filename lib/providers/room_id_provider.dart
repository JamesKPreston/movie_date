import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/notifier/room_id_notifier.dart';

final roomIdProvider = AsyncNotifierProvider<RoomIdNotifier, String>(() {
  return RoomIdNotifier();
});
