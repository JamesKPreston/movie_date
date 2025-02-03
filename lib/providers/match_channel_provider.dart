import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/movie_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_date/models/match_model.dart';

part 'match_channel_provider.g.dart';

@riverpod
Stream<List<int>> matchChannel(Ref ref) {
  final supabaseClient = Supabase.instance.client;
  final matchChannel = supabaseClient.channel('public:match');
  final controller = StreamController<Match>();
  final movieIds = <int>[];
  
  void subscribeToChannel() {
    matchChannel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'match',
      ),
      (payload, [ref]) {
        final match = Match.fromMap(payload['new']);
        controller.add(match);
      },
    );

    matchChannel.subscribe((status, [error]) {
      if (status != 'SUBSCRIBED') {
        // Retry subscription after delay if failed
        Future.delayed(const Duration(seconds: 5), subscribeToChannel);
      }
    });
  }

  // Initial subscription
  subscribeToChannel();

  ref.onDispose(() {
    matchChannel.unsubscribe();
    controller.close();
  });

  return controller.stream.asyncExpand((match) async* {
    if (match.match_count >= 2) {
      // Use read instead of watch since this is inside a stream
      final movieService = ref.read(movieServiceProvider);
      final isValidMatch = await movieService.validateMatchInCurrentRoom(match);
      
      if (isValidMatch && !movieIds.contains(match.movie_id)) {
        movieIds.add(match.movie_id);
        yield List<int>.from(movieIds); // Create new list to ensure state update
      }
    }
  });
}
