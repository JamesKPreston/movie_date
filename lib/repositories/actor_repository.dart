import 'package:jp_moviedb/types/person.dart';

abstract class ActorRepository {
  Future<List<Person>> getActors(String names);
}
