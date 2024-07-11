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
    var result = await MovieService().getMovies();
    setState(() {
      movies = result;
      count = movies.length;
    });
  }

  void test() async {
    var result = await MovieService().getMovieChoices();
    var result2 = await MovieService().getUsersMovieChoices();

    print(result);
    print('and now result2');
    print(result2);
    // setState(() {
    //   movieChoices = result;
    // });

    // List<int> movieChoices = [];
    // movieChoices.add(314);
    // movieChoices.add(78);

    // await MovieService()
    //     .saveMovie(movieChoices, '00b7ea42-d9ef-4e60-99ad-226ca02c2dd2', '8e9e5756-3d89-4329-9c08-8b46ded21184');
  }

  @override
  void initState() {
    super.initState();
    //test();
    loadMovies(page);
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
                  if (count == 0) {
                    page++;
                    loadMovies(page);
                  }
                  switch (direction) {
                    case DismissDirection.endToStart:
                      // ScaffoldMessenger.of(context)
                      //     .showSnackBar(SnackBar(content: Text('${item.title} removed and count is now $count ')));
                      break;
                    case DismissDirection.startToEnd:
                      MovieService().saveMovie(item.id);
                      // ScaffoldMessenger.of(context)
                      //     .showSnackBar(SnackBar(content: Text('${item.title} liked and count is now $count')));
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
