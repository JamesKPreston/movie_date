import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/types/person.dart';
import 'package:movie_date/providers/actor_repository_provider.dart';

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

  Future<void> _searchActors() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final actorRepo = ref.read(actorRepositoryProvider);
      var actors = await actorRepo.getActors(_searchController.text.trim());
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
    // if (!temp) {
    //   return AlertDialog(
    //     title: const Text('Confirm Exit'),
    //     content: const Text('Do you wish to leave the page without saving?'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text('Leave'),
    //       ),
    //     ],
    //   );
    // }
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final navigator = Navigator.of(context);
            if (!selectedActorsModified) {
              navigator.pop();
            } else {
              final shouldPop = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Exit'),
                  content: const Text('Do you wish to leave the page without saving?'),
                  actions: [
                    TextButton(
                      onPressed: () => navigator.pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => navigator.pop(true),
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
              if (shouldPop) {
                navigator.pop();
              }
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Select Actors'),
            backgroundColor: Colors.deepPurple,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_outlined, color: Colors.white),
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
        ));
  }
}
