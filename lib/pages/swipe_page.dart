import 'package:flutter/material.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  int count = 0;
  int page = 1;

  void loadMovies(int page) async {
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );

    movies.clear();
    MovieFilters filters = MovieFilters();
    filters.page = page;
    filters.language = 'en';
    filters.primaryReleaseDateGte = DateTime(1986, 01, 01);
    filters.primaryReleaseDateLte = DateTime(1991, 01, 01);
    var result = await api.discover.getMovies(filters);
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
