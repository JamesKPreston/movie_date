import 'package:flutter/material.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/models/movie_choices.dart';
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
  late TmdbApi api;
  List<Movie> movies = [];
  List<MovieChoice> movieChoices = [];
  int count = 0;
  int page = 1;

  void loadMovies(int page) async {
    var result = await MovieService().getMovies(page);
    setState(() {
      movies = result;
      count = movies.length;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovies(page);
  }

  void checkForMatch(int movieId) async {
    bool matchFound = await MovieService().isMovieSaved(movieId);
    if (matchFound) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match Found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final item = movies[index];
            return Dismissible(
                key: Key(item.id.toString()),
                onDismissed: (direction) {
                  count--;
                  setState(() {
                    movies.removeAt(index);
                  });
                  if (count == 0) {
                    page++;
                    loadMovies(page);
                  }
                  switch (direction) {
                    case DismissDirection.startToEnd:
                      MovieService().saveMovie(item.id);
                      setState(() {
                        checkForMatch(item.id);
                      });
                      break;
                    default:
                      break;
                  }
                },
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        children: [
                          Text(item.title),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'Release Date ${item.releaseDate.year.toString()}-${item.releaseDate.month.toString()}-${item.releaseDate.day.toString()}'),
                          )
                        ],
                      ),
                      Text(item.overview)
                    ],
                  ),
                  subtitle: Image.network(item.posterPath),
                ));
          },
        ),
      ),
    );
  }
}
