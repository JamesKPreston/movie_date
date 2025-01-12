import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/repositories/actor_repository.dart';

class MockTmdbActorRepository implements ActorRepository {
  Future<List<Person>> getActors(String names) async {
    throw UnimplementedError();
  }
}
