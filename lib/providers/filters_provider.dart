import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/providers/members_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final filtersProvider = StreamProvider.autoDispose<Room>((ref) {
  final supabaseClient = Supabase.instance.client;
  final filtersChannel = supabaseClient.channel('public:rooms');
  final controller = StreamController<Room>();

  filtersChannel.on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(
      event: '*',
      schema: 'public',
      table: 'rooms',
    ),
    (payload, [ref]) {
      final room = (Room.fromMap(payload['new']));
      controller.add(room);
    },
  );

  filtersChannel.subscribe();

  ref.onDispose(() {
    filtersChannel.unsubscribe();
    controller.close();
  });

  return controller.stream.asyncExpand((room) async* {
    final membersService = ref.read(membersServiceProvider);
    final currentRoom = await membersService.getRoomByUserId(supabaseClient.auth.currentUser!.id);
    if (currentRoom.id == room.id) {
      yield room;
    }
  });
});
