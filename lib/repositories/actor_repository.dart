import 'package:movie_date/api/types/person.dart';

abstract class ActorRepository {
  Future<List<Person>> getActors(String names);
}
