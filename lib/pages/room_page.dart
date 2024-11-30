import 'package:flutter/material.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:movie_date/services/actor_service.dart';
import 'package:movie_date/services/genre_service.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/services/room_service.dart';

import 'package:movie_date/models/room.dart';

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
  List<int> selectedGenres = [];
  List<String> selectedActors = [];
  DateTime? releaseDateGte;
  DateTime? releaseDateLte;

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

  Future<void> createRoom() async {
    List<MovieFilters> filters = [];
    List<String> selectedActorIds = [];
    MovieFilters filter = MovieFilters(
      page: 1,
    );

    for (var actor in selectedActors) {
      var result = await ActorService().getActors(actor.trim());
      selectedActorIds.add(result.first.id.toString());
    }
    filter.withGenres = selectedGenres.join('|');
    filter.withCast = selectedActorIds.join('|');
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

    var result = await ProfileService().updateProfileRoomId(newRoomId);
  }

  Future<void> _selectDate(BuildContext context, bool isGte) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isGte) {
          releaseDateGte = picked;
        } else {
          releaseDateLte = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Genres'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Genres:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: genres.map((genre) {
                  return FilterChip(
                    label: Text(genre.name),
                    selected: selectedGenres.contains(genre.id),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedGenres.add(genre.id);
                        } else {
                          selectedGenres.remove(genre.id);
                        }
                      });
                    },
                    selectedColor: Colors.deepPurple.withOpacity(0.3),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Actor Name:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  labelText: 'Enter Actor Name',
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                onChanged: (value) {
                  selectedActors.clear();
                  selectedActors = value.split(",");
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Date >=',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDate(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: Text(releaseDateGte != null ? releaseDateGte.toString().split(' ')[0] : 'Select Start Date'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Date <=',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDate(context, false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: Text(releaseDateLte != null ? releaseDateLte.toString().split(' ')[0] : 'Select End Date'),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createRoom();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
