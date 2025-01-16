import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_date/models/match_model.dart';

part 'match_channel_provider.g.dart';

@riverpod
Stream<List<int>> matchChannel(Ref ref) {
  final supabaseClient = Supabase.instance.client;
  final matchChannel = supabaseClient.channel('public:match');
  final controller = StreamController<Match>();

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

  matchChannel.subscribe();

  ref.onDispose(() {
    matchChannel.unsubscribe();
    controller.close();
  });

  final movieIds = <int>[];

  return controller.stream.asyncExpand((match) async* {
    if (match.match_count >= 2) {
      movieIds.add(match.movie_id);
      yield movieIds.toList();
    }
    // final movieService = ref.read(movieServiceProvider);
    // final isSaved = await movieService.isMovieSaved(movieId);

    // if (isSaved && !movieIds.contains(movieId)) {
    //   movieIds.add(movieId);
    //   yield movieIds.toList();
    // }
  });
}
