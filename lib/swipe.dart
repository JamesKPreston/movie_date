import 'package:flutter/material.dart';
import 'package:jp_moviedb/api.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Swipe extends StatefulWidget {
  const Swipe({super.key});

  @override
  State<Swipe> createState() => _SwipeState();
}

class _SwipeState extends State<Swipe> {
  late TmdbApi api;
  List<Movie> movies = [];

  void loadMovies() async {
    await dotenv.load();
    api = TmdbApi(
      dotenv.env['API_KEY']!,
    );
    MovieFilters filters = MovieFilters();
    filters.page = 1;
    filters.language = 'en';
    filters.primaryReleaseDateGte = DateTime(1986, 01, 01);
    filters.primaryReleaseDateLte = DateTime(1991, 01, 01);
    var result = await api.discover.getMovies(filters);
    setState(() {
      movies = result;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovies();
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
                  switch (direction) {
                    case DismissDirection.endToStart:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} removed')));
                      break;
                    case DismissDirection.startToEnd:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} liked')));
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
