import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/providers/match_channel_provider.dart';
import 'package:movie_date/tmdb/providers/genre_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/match_channel_handler.dart';
import 'package:movie_date/widgets/calendar_widget.dart';

class RoomPage extends ConsumerStatefulWidget {
  const RoomPage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const RoomPage());
  }

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage> {
  List<Genre> genres = [];
  List<Genre> selectedGenres = [];
  List<Person> selectedActors = [];
  DateTime? releaseDateGte;
  DateTime? releaseDateLte;
  String roomCode = '';
  TextEditingController actorController = TextEditingController();
  TextEditingController genreController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchGenres().then((_) => _loadFilters());
  }

  Future<void> _loadFilters() async {
    if (genres.isEmpty) {
      return;
    }
    var profileRepo = ref.read(profileRepositoryProvider);
    var roomService = await ref.read(roomServiceProvider);

    var userId = await profileRepo.getCurrentUserId();
    var room = await roomService.getRoomByUserId(userId);
    final filters = room.filters;
    if (filters.isNotEmpty) {
      await PopulateFiltersScreen(filters);
    }
  }

  Future<void> PopulateFiltersScreen(List<MovieFilters> filters) async {
    setState(() {
      if (filters.first.withGenres != null && filters.first.withGenres!.isNotEmpty) {
        selectedGenres = filters.first.withGenres!.split('|').map((genreId) {
          return genres.firstWhere((genre) => genre.id == int.parse(genreId));
        }).toList();
        genreController.text = selectedGenres.map((genre) => genre.name).join(', ');
      } else {
        selectedGenres = [];
        genreController.clear();
      }

      selectedActors = filters.first.persons ?? [];
      actorController.text = selectedActors.map((actor) => actor.name).join(', ');

      releaseDateGte = filters.first.primaryReleaseDateGte;
      releaseDateLte = filters.first.primaryReleaseDateLte;
    });
  }

  Future<void> fetchGenres() async {
    final genreRepo = ref.read(genreRepositoryProvider);
    var result = await genreRepo.getGenres();

    setState(() {
      genres = result;
    });
  }

  Future<void> _showGenreDialog() async {
    await FilterListDialog.display<Genre>(
      context,
      listData: genres,
      selectedListData: selectedGenres,
      choiceChipLabel: (genre) => genre!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (genre, query) {
        return genre.name.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedGenres = List.from(list!);
          genreController.text = selectedGenres.map((genre) => genre.name).join(', ');
        });
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showActorPage() async {
    final savedActors = List<Person>.from(selectedActors);

    // Navigate to the ActorPage and wait for the result
    final result = await context.pushNamed<List<Person>>(
      'actors',
      extra: selectedActors, // Pass the selected actors
    );

    // Update the state based on the result
    setState(() {
      selectedActors = result ?? savedActors;
      actorController.text = selectedActors.map((actor) => actor.name).join(', ');
    });
  }

  Future<void> _showCalendar(bool isGte) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            height: 400,
            child: CalendarWidget(
              onConfirm: (DateTime selectedDate) {
                setState(() {
                  if (isGte) {
                    releaseDateGte = selectedDate;
                  } else {
                    releaseDateLte = selectedDate;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> updateFilters() async {
    List<MovieFilters> filters = [];
    MovieFilters filter = MovieFilters(
      page: 1,
    );
    filter.withGenres = selectedGenres.map((genre) => genre.id).join('|');
    filter.withCast = selectedActors.map((actor) => actor.id).join('|');
    filter.persons = selectedActors;
    filter.language = 'en';
    filter.primaryReleaseDateGte =
        releaseDateGte != null ? releaseDateGte : DateTime.parse('${DateTime.now().year}-01-01');
    filter.primaryReleaseDateLte = releaseDateLte;
    filters.add(filter);

    await ref.read(roomServiceProvider).updateFiltersForRoom(filters);
    context.goNamed('home');
  }

  final InputDecoration commonInputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    prefixIcon: const Icon(Icons.category, color: Colors.black),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen(matchChannelProvider, (previous, next) {
      matchChannelHandler(context, next);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filters',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genres:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: genreController,
                      readOnly: true,
                      decoration: commonInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.category, color: Colors.black),
                      ),
                      onTap: _showGenreDialog,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _showGenreDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Actors:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: actorController,
                      readOnly: true,
                      onTap: _showActorPage,
                      decoration: commonInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.person, color: Colors.black),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: _showActorPage,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Start:',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            releaseDateGte != null
                                ? releaseDateGte!.toString().split(' ')[0]
                                : DateTime.parse('${DateTime.now().year}-01-01').toString().split(' ')[0],
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.black),
                          onPressed: () {
                            _showCalendar(true);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'End:',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            releaseDateLte != null ? releaseDateLte!.toString().split(' ')[0] : '',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.black),
                          onPressed: () {
                            _showCalendar(false);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGenres = [];
                          selectedActors = [];
                          releaseDateGte = null;
                          releaseDateLte = null;
                          genreController.clear();
                          actorController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                      ),
                      child: const Text('Clear Filters'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        updateFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
