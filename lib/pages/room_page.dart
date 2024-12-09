import 'package:flutter/material.dart';
import 'package:jp_moviedb/filters/movie.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/services/actor_service.dart';
import 'package:movie_date/services/genre_service.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/services/room_service.dart';

import 'package:movie_date/models/room.dart';
import 'package:random_string/random_string.dart';

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
  String roomCode = '';
  TextEditingController actorController = TextEditingController();

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
    roomCode = randomAlphaNumeric(6).toUpperCase();
    ProfileService().updateProfileRoomCode(roomCode);
    List<MovieFilters> filters = [];
    //List<String> selectedActorIds = [];
    MovieFilters filter = MovieFilters(
      page: 1,
    );

    // for (var actor in selectedActors) {
    //   var result = await ActorService().getActors(actor.trim());
    //   selectedActorIds.add(result.first.id.toString());
    // }
    filter.withGenres = selectedGenres.join('|');
    filter.withCast = selectedActors.join('|');
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

  void _showActorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: ActorService().getActors(actorController.text.trim()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to load actors'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            } else {
              var actors = snapshot.data;

              int currentIndex = 0;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                        'Select Actor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (actors!.isNotEmpty)
                          Column(
                            children: [
                              //Text(actors[currentIndex].name),
                              Text(actors[currentIndex].name ?? 'Unknown'),
                              SizedBox(height: 10),
                              if (actors[currentIndex].profilePath != null &&
                                  actors[currentIndex].profilePath != 'https://image.tmdb.org/t/p/originalnull')
                                Center(
                                  child: Image.network(
                                    '${actors[currentIndex].profilePath}',
                                    height: 150,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 150,
                                    color: Colors.grey,
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: currentIndex > 0
                                        ? () {
                                            setState(() {
                                              currentIndex--;
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: currentIndex < actors.length - 1
                                        ? () {
                                            setState(() {
                                              currentIndex++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          Text('No actors found'),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.close, color: Colors.red, size: 30),
                          ),
                          TextButton(
                            onPressed: () {
                              if (actors.isNotEmpty) {
                                setState(() {
                                  selectedActors.add(actors[currentIndex].id.toString());
                                });
                              }
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.check, color: Colors.green, size: 30),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Genres',
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
              const SizedBox(height: 8),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: actorController,
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
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilterChip(
                    label: Text(releaseDateGte != null ? releaseDateGte.toString().split(' ')[0] : 'Select Start Date'),
                    selected: releaseDateGte != null,
                    onSelected: (bool selected) {
                      if (selected) {
                        _selectDate(context, true);
                      } else {
                        setState(() {
                          releaseDateGte = null;
                        });
                      }
                    },
                    selectedColor: Colors.deepPurple.withOpacity(0.3),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  ),
                  FilterChip(
                    label: Text(releaseDateLte != null ? releaseDateLte.toString().split(' ')[0] : 'Select End Date'),
                    selected: releaseDateLte != null,
                    onSelected: (bool selected) {
                      if (selected) {
                        _selectDate(context, false);
                      } else {
                        setState(() {
                          releaseDateLte = null;
                        });
                      }
                    },
                    selectedColor: Colors.deepPurple.withOpacity(0.3),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: FilterChip(
                  label: const Text('Create Room'),
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
