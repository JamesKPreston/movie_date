import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/person.dart';

class ActorService {
  late TmdbApi api;
  int count = 0;

  Future<List<Person>> getActors(String names) async {
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );
    return await api.search.getPerson(names);
  }
}
