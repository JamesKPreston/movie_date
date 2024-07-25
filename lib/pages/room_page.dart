import 'package:flutter/material.dart';
import 'package:jp_moviedb/types/genre.dart';
import 'package:movie_date/services/genre_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Genres'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
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
                // Save actor's name
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle button press
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
    );
  }
}
