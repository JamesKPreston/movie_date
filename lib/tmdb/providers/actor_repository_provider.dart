import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/api/types/person.dart';
import 'package:movie_date/repositories/actor_repository.dart';
import 'package:movie_date/tmdb/repositories/actor_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'actor_repository_provider.g.dart';

@riverpod
ActorRepository actorRepository(Ref ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return TmdbActorRepository(apiKey);
}

@riverpod
Future<List<Person>> actorFuture(Ref ref, String actors) async {
  final repository = ref.watch(actorRepositoryProvider);
  return repository.getActors(actors);
}
