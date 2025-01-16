import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/tmdb/providers/actor_repository_provider.dart';

class ActorPage extends ConsumerStatefulWidget {
  final List<Person>? currentlySelectedActors;

  const ActorPage({Key? key, this.currentlySelectedActors}) : super(key: key);

  @override
  _ActorPageState createState() => _ActorPageState();
}

class _ActorPageState extends ConsumerState<ActorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Person> searchResults = [];
  late List<Person> selectedActors;
  bool isLoading = false;
  bool selectedActorsModified = false;

  @override
  void initState() {
    super.initState();
    selectedActors = widget.currentlySelectedActors ?? [];
  }

  void _addActor(Person actor) {
    selectedActorsModified = true;
    if (!selectedActors.contains(actor)) {
      setState(() {
        selectedActors.add(actor);
      });
    }
  }

  void _removeActor(Person actor) {
    selectedActorsModified = true;
    setState(() {
      selectedActors.remove(actor);
    });
  }

  void _saveActors() {
    selectedActorsModified = false;
    Navigator.of(context).pop(selectedActors);
  }

  @override
  Widget build(BuildContext context) {
    if (_searchController.text.trim().isEmpty) {
      searchResults = [];
    } else {
      var actorsProvider = ref.watch(actorFutureProvider(_searchController.text.trim()));
      actorsProvider.when(
        data: (actors) {
          searchResults = actors;
          isLoading = false;
        },
        loading: () {
          isLoading = true;
        },
        error: (error, stackTrace) {
          print(error);
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          if (!selectedActorsModified) {
            navigator.pop();
          } else {
            final shouldSave = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Unsaved Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                content: const Text(
                  'You have unsaved changes. Do you want to save them before exiting?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero, // Ensures text fits neatly within the button
                      ),
                      onPressed: () => navigator.pop(false),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Exit Without Saving',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero, // Ensures text fits neatly within the button
                      ),
                      onPressed: () => navigator.pop(true),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Save and Exit',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (!shouldSave) {
              navigator.pop();
            } else {
              _saveActors();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Actors'),
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.white), // Makes the back arrow white
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white, size: 30), // Changed to floppy disk and increased size
              onPressed: _saveActors,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Actor',
                  labelStyle: const TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black), // Icon color changed to black
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Text input color
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: Column(
                    children: [
                      if (searchResults.isNotEmpty) ...[
                        const Text(
                          'Search Results:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                                  icon: const Icon(Icons.add, color: Colors.grey),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedActors.length,
                          itemBuilder: (context, index) {
                            final actor = selectedActors[index];
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
      ),
    );
  }
}
