import 'package:flutter/material.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/services/movie_service.dart';

class MatchFoundPage extends StatefulWidget {
  final int movieId;

  const MatchFoundPage({super.key, required this.movieId});

  static Route route(int movieId) {
    return MaterialPageRoute<void>(builder: (_) => MatchFoundPage(movieId: movieId));
  }

  @override
  State<MatchFoundPage> createState() => _MatchFoundPageState();
}

class _MatchFoundPageState extends State<MatchFoundPage> {
  List<Movie> movies = [];
  bool isLoading = false;

  void loadMovie(int movieId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    Movie match = await MovieService().getMovie(movieId);
    setState(() {
      movies.add(match);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovie(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Vibrant background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)], // Vibrant Tinder-like gradient
              ),
            ),
          ),
          SafeArea(
            child: movies.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: movies.map((movie) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Stylized text indicating Match Found
                                const Text(
                                  'Match Found',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your Movie Tonight!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Fully visible movie poster, scaled to avoid black borders
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    movie.posterPath,
                                    fit: BoxFit.contain, // Ensure full visibility of the poster
                                    width: double.infinity, // Take up all available width
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Movie Info (title, year, etc.)
                                Text(
                                  '${movie.title}, ${movie.releaseDate.year}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Additional movie info (runtime, rating)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.timer, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${movie.runtime} min',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Icon(Icons.star, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${movie.voteAverage}/10',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Movie Description (overview)
                                Text(
                                  movie.overview,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
