import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/repositories/actor_repository.dart';
import 'package:movie_date/tmdb/repositories/actor_repository.dart';

final actorRepositoryProvider = Provider<ActorRepository>((ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return TmdbActorRepository(apiKey);
});

final actorFutureProvider = FutureProvider.family<List<Person>, String>((ref, actors) async {
  final repository = ref.watch(actorRepositoryProvider);
  return repository.getActors(actors);
});
