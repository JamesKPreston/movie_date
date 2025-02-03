import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Assuming you're using Riverpod

void matchChannelHandler(
  BuildContext context,
  AsyncValue<List<int>> next,
) {
  next.when(
    data: (movieIds) {
      if (movieIds.isNotEmpty) {
        var movieId = movieIds.last;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.goNamed(
            'match_found',
            extra: movieId,
          );
        });
      }
    },
    loading: () {},
    error: (error, stackTrace) {
      print('Error in match channel: $error');
    },
  );
}
