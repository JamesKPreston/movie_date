import 'package:movie_date/api/api.dart';
import 'package:movie_date/api/types/person.dart';
import 'package:movie_date/repositories/actor_repository.dart';

class TmdbActorRepository implements ActorRepository {
  final TmdbApi api;

  TmdbActorRepository(String apiKey) : api = TmdbApi(apiKey);

  Future<List<Person>> getActors(String names) async {
    return await api.search.getPerson(names);
  }
}
