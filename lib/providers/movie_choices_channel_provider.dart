import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_date/providers/movie_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final movieChoicesChannelProvider = StreamProvider.autoDispose<List<int>>((ref) {
  final supabaseClient = Supabase.instance.client;
  final movieChoicesChannel = supabaseClient.channel('public:moviechoices');
  final controller = StreamController<int>();

  movieChoicesChannel.on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(
      event: '*',
      schema: 'public',
      table: 'moviechoices',
    ),
    (payload, [ref]) {
      final movieId = (payload['new']['movie_id'] as double).toInt();
      controller.add(movieId);
    },
  );

  movieChoicesChannel.subscribe();

  ref.onDispose(() {
    movieChoicesChannel.unsubscribe();
    controller.close();
  });

  final movieIds = <int>[];

  return controller.stream.asyncExpand((movieId) async* {
    final movieService = ref.read(movieServiceProvider);
    final isSaved = await movieService.isMovieSaved(movieId);

    if (isSaved && !movieIds.contains(movieId)) {
      movieIds.add(movieId);
      yield movieIds.toList();
    }
  });
});
