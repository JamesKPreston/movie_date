import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_date/repositories/actor_repository.dart';

final actorRepositoryProvider = Provider<ActorRepository>((ref) {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("API_KEY is missing or empty in the .env file");
  }
  return ActorRepository(apiKey);
});
