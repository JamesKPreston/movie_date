import 'package:flutter/material.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/services/movie_service.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SwipePage());
  }

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<Movie> movies = [];
  int page = 1;
  bool isLoading = false;

  void loadMovies(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    var result = await MovieService().getMovies(page);
    setState(() {
      movies.addAll(result);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovies(page);
  }

  void handleDismissed(Movie movie) async {
    // Remove movie from the list
    setState(() {
      movies.remove(movie);
    });

    // Check if more movies need to be loaded
    if (movies.isEmpty && !isLoading) {
      page++;
      loadMovies(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // More vibrant gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Dark cyan
                  Color(0xFF203A43), // Deep teal
                  Color(0xFF2C5364), // Navy
                ],
              ),
            ),
          ),
          SafeArea(
            child: movies.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return Dismissible(
                        key: Key(movie.id.toString()),
                        onDismissed: (direction) {
                          handleDismissed(movie);

                          if (direction == DismissDirection.startToEnd) {
                            MovieService().saveMovie(movie.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Match Found')),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image that fills available space
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 2 / 3, // Ensures movie poster ratio
                                  child: Image.network(
                                    movie.posterPath,
                                    fit: BoxFit.cover, // Ensures image covers without black bars
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Release Date below image
                              Text(
                                'Release Date: ${movie.releaseDate.year}-${movie.releaseDate.month.toString().padLeft(2, '0')}-${movie.releaseDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Movie description
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    movie.overview,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
