import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/models/member_model.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/providers/genre_provider.dart';
import 'package:movie_date/providers/members_repository_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_repository_provider.dart';
import 'package:movie_date/models/room_model.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:movie_date/widgets/actor_widget.dart';
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
    final filters = await getCurrentFilters(ref);
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

  Future<void> createRoom() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final membersRepo = ref.read(membersRepositoryProvider);
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

    var roomRepo = await ref.read(roomRepositoryProvider);
    var roomId = await membersRepo.getRoomIdByUserId(supabase.auth.currentUser!.id);
    var room = await roomRepo.getRoomByRoomId(roomId);
    var newRoomId = await roomRepo.addRoom(
      Room(
        id: room.id,
        filters: filters,
        room_code: room.room_code,
      ),
    );

    final user = supabase.auth.currentUser;
    //add current user to the members of that room
    var member = Member(
      id: user!.id,
      room_id: newRoomId,
      user_id: user.id,
      email: await profileRepo.getEmailById(user.id),
    );

    var memberRepo = ref.read(membersRepositoryProvider);
    await memberRepo.addMember(member);

    Navigator.of(context).pushAndRemoveUntil(MainPage.route(), (route) => false);
  }

  Future<List<MovieFilters>> getCurrentFilters(WidgetRef ref) async {
    var roomService = await ref.read(roomServiceProvider);
    var room = await roomService.getRoomByUserId(supabase.auth.currentUser!.id);

    return room.filters;
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
        title: Text(
          'Filters',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                    icon: const Icon(Icons.search, color: Colors.deepPurple),
                    onPressed: _showActorDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                            releaseDateGte != null
                                ? releaseDateGte!.toString().split(' ')[0]
                                : DateTime.parse('${DateTime.now().year}-01-01').toString().split(' ')[0],
                            style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.deepPurple),
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
                          style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            releaseDateLte != null ? releaseDateLte!.toString().split(' ')[0] : '',
                            style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
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
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Clear Filters'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        createRoom();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Save Filters'),
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
