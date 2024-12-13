import 'package:flutter/material.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/services/actor_service.dart';

class ActorWidget extends StatefulWidget {
  final Function(List<Person>) onSelectedActors;
  final List<Person>? currentlySelectedActors;

  const ActorWidget({Key? key, required this.onSelectedActors, this.currentlySelectedActors}) : super(key: key);

  @override
  _ActorWidgetState createState() => _ActorWidgetState();
}

class _ActorWidgetState extends State<ActorWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Person> searchResults = [];
  late List<Person> selectedActors;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize selectedActors to the passed list or an empty list
    selectedActors = widget.currentlySelectedActors ?? [];
  }

  Future<void> _searchActors() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      var actors = await ActorService().getActors(_searchController.text.trim());
      setState(() {
        searchResults = actors;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load actors. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addActor(Person actor) {
    if (!selectedActors.contains(actor)) {
      setState(() {
        selectedActors.add(actor);
      });
    }
  }

  void _removeActor(Person actor) {
    setState(() {
      selectedActors.remove(actor);
    });
  }

  void _saveActors() {
    widget.onSelectedActors(selectedActors);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const Text(
              'Search and Select Actors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Actor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepPurple),
                  onPressed: _searchActors,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchResults.isNotEmpty) ...[
                      const Text(
                        'Search Results:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchResults
                              .where((actor) =>
                                  actor.profilePath != null &&
                                  actor.profilePath != 'https://image.tmdb.org/t/p/originalnull')
                              .length,
                          itemBuilder: (context, index) {
                            final actor = searchResults
                                .where((actor) =>
                                    actor.profilePath != null &&
                                    actor.profilePath != 'https://image.tmdb.org/t/p/originalnull')
                                .toList()[index];
                            return ListTile(
                              leading: actor.profilePath != null
                                  ? Image.network(
                                      actor.profilePath!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.person, size: 50, color: Colors.grey),
                              title: Text(actor.name ?? 'Unknown'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add, color: Colors.deepPurple),
                                onPressed: () => _addActor(actor),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else
                      const Text('No actors found'),
                    const Divider(),
                    const Text(
                      'Selected Actors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedActors.length,
                        itemBuilder: (context, index) {
                          final actor = selectedActors[index];
                          return ListTile(
                            leading: actor.profilePath != null &&
                                    actor.profilePath != 'https://image.tmdb.org/t/p/originalnull'
                                ? Image.network(
                                    actor.profilePath!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.person, size: 50, color: Colors.grey),
                            title: Text(actor.name ?? 'Unknown'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeActor(actor),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveActors,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
