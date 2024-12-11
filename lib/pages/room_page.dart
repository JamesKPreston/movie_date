import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/pages/test_page.dart';
import 'package:movie_date/services/actor_service.dart';
import 'package:movie_date/services/genre_service.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/services/room_service.dart';
import 'package:movie_date/models/room.dart';
import 'package:movie_date/widgets/actor.dart';
import 'package:random_string/random_string.dart';
import 'package:movie_date/widgets/calendar.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const RoomPage());
  }

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
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
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    var result = await GenreService().getGenres();

    setState(() {
      genres = result;
    });
  }

  Future<void> _showFilterDialog() async {
    await FilterListDialog.display<Genre>(
      context,
      listData: genres,
      selectedListData: selectedGenres,
      choiceChipLabel: (genre) => genre!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (genre, query) {
        return genre.name!.toLowerCase().contains(query.toLowerCase());
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

  Future<void> _showActorDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ActorWidget(
          onSelectedActors: (selected) {
            setState(() {
              selectedActors = selected;
              actorController.text = selectedActors.map((actor) => actor.name).join(', ');
            });
          },
          currentlySelectedActors: selectedActors,
        );
      },
    );
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
            height: 400, // Adjust the height as needed
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

  Future<void> createRoom() async {
    roomCode = randomAlphaNumeric(6).toUpperCase();
    ProfileService().updateProfileRoomCode(roomCode);
    List<MovieFilters> filters = [];
    MovieFilters filter = MovieFilters(
      page: 1,
    );
    filter.withGenres = selectedGenres.map((genre) => genre.id).join('|');
    filter.withCast = selectedActors.map((actor) => actor.id).join('|');
    filter.language = 'en';
    filter.primaryReleaseDateGte = releaseDateGte;
    filter.primaryReleaseDateLte = releaseDateLte;
    filters.add(filter);

    var newRoomId = await RoomService().addRoom(
      Room(
        id: '1',
        filters: filters,
      ),
    );

    await ProfileService().updateProfileRoomId(newRoomId);
    Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
  }

  final InputDecoration commonInputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    prefixIcon: const Icon(Icons.category, color: Colors.deepPurple),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genres:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: genreController,
                      readOnly: true,
                      decoration: commonInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.category, color: Colors.deepPurple),
                      ),
                      onTap: _showFilterDialog,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Actors:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: actorController,
                      readOnly: true,
                      onTap: _showActorDialog,
                      decoration: commonInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.deepPurple),
                    onPressed: _showActorDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Date:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
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
                          style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            releaseDateGte != null ? releaseDateGte!.toString().split(' ')[0] : '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.deepPurple),
                          onPressed: () {
                            _showCalendar(true);
                            //_selectDate(context, true);
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
                          style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            releaseDateLte != null ? releaseDateLte!.toString().split(' ')[0] : '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.deepPurple),
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
              Center(
                child: FilterChip(
                  label: const Text('Save Filters'),
                  selected: false,
                  onSelected: (bool selected) {
                    createRoom();
                  },
                  selectedColor: Colors.deepPurple.withOpacity(0.3),
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
