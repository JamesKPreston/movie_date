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
      title: const Center(
        child: Text(
          'Search and Select Actors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (searchResults.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: searchResults
                      .where((actor) =>
                          actor.profilePath != null && actor.profilePath != 'https://image.tmdb.org/t/p/originalnull')
                      .length,
                  itemBuilder: (context, index) {
                    final actor = searchResults
                        .where((actor) =>
                            actor.profilePath != null && actor.profilePath != 'https://image.tmdb.org/t/p/originalnull')
                        .toList()[index];
                    return ListTile(
                      leading: Image.network(
                        actor.profilePath!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(actor.name ?? 'Unknown'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.deepPurple),
                        onPressed: () => _addActor(actor),
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No actors found'),
            const Divider(),
            const Text(
              'Selected Actors:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: selectedActors.length,
                itemBuilder: (context, index) {
                  final actor = selectedActors[index];
                  return ListTile(
                    leading: actor.profilePath != null && actor.profilePath != 'https://image.tmdb.org/t/p/originalnull'
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
