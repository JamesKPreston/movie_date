// match_channel_handler.dart

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.goNamed(
            'match_found',
            extra: movieIds.first,
          );
        });
      }
    },
    loading: () {},
    error: (error, stackTrace) {
      print('Error loading movie choices: $error');
    },
  );
}
