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
      ),
      body: movies.isEmpty
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
                        // Row for Title and Release Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Release Date: ${movie.releaseDate.year.toString()}-${movie.releaseDate.month.toString().padLeft(2, '0')}-${movie.releaseDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Centered Image
                        Flexible(
                          child: Center(
                            child: Image.network(
                              movie.posterPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Overview with flexible text
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              movie.overview,
                              style: const TextStyle(fontSize: 16),
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
    );
  }
}
