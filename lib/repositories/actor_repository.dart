import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/person.dart';

class ActorRepository {
  final TmdbApi api;

  ActorRepository(String apiKey) : api = TmdbApi(apiKey);

  Future<List<Person>> getActors(String names) async {
    return await api.search.getPerson(names);
  }
}
