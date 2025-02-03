import 'package:dio/dio.dart';

class YouTubeRepository {
  final String apiKey;
  final Dio _dio;

  YouTubeRepository(this.apiKey) : _dio = Dio();

  Future<String> searchMovieTrailers(String query) async {
    const String baseUrl = 'https://www.googleapis.com/youtube/v3/search';
    final response = await _dio.get(baseUrl, queryParameters: {
      'part': 'snippet',
      'type': 'video',
      'q': '$query trailer',
      'key': apiKey,
    });

    if (response.statusCode == 200) {
      return response.data['items'][0]['id']['videoId'];
    } else {
      throw Exception('Failed to load trailers');
    }
  }
}
