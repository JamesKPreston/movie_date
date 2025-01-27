import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/models/watch_options.dart';
import 'package:movie_date/tmdb/providers/movie_repository_provider.dart';
import 'package:movie_date/providers/movie_service_provider.dart';

class MatchFoundPage extends ConsumerStatefulWidget {
  final int movieId;

  const MatchFoundPage({super.key, required this.movieId});

  static Route route(int movieId) {
    return MaterialPageRoute<void>(builder: (_) => MatchFoundPage(movieId: movieId));
  }

  @override
  ConsumerState<MatchFoundPage> createState() => _MatchFoundPageState();
}

class _MatchFoundPageState extends ConsumerState<MatchFoundPage> {
  List<Movie> movies = [];
  List<WatchOption> watchOptions = [];
  bool isLoading = false;

  void loadMovie(int movieId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final movieRepo = ref.read(movieRepositoryProvider);
    Movie match = await movieRepo.getMovie(movieId);
    watchOptions = await movieRepo.getMovieWatchOptions(movieId);
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: const [
                      Text(
                        'Match Found',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Movie Tonight!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: movies.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: movies.map((movie) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        movie.posterPath,
                                        fit: BoxFit.contain,
                                        width: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '${movie.title}, ${movie.releaseDate.year}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Where to Watch:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: watchOptions.map((option) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('${option.iconPath}', width: 60, height: 60),
                              const SizedBox(height: 4),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final movieService = ref.read(movieServiceProvider);
                      await movieService.deleteMovieChoicesByRoomId();
                      context.goNamed('home');
                    },
                    child: const Text(
                      'Back to Start',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
