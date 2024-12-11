import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/pages/match_found_page.dart';
import 'package:movie_date/services/movie_service.dart';
import 'package:movie_date/services/profile_service.dart';
import 'package:movie_date/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SwipePage());
  }

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<Movie> movies = [];
  int page = 1;
  bool isLoading = false;
  String? roomCode;
  RealtimeChannel? movieChoicesChannel;
  int swipeCount = 0;

  @override
  void initState() {
    super.initState();
    loadRoomCode();
    loadMovies(page);
    listenToMovieChoices();
    listenToFilterUpdates();
  }

  @override
  void dispose() {
    // Unsubscribe from the real-time channel
    movieChoicesChannel?.unsubscribe();
    super.dispose();
  }

  void loadRoomCode() async {
    roomCode = await ProfileService().getRoomCodeById(supabase.auth.currentUser!.id);
    setState(() {});
  }

  void loadMovies(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    var result = await MovieService().getMovies(page);
    setState(() {
      movies.addAll(result);
      isLoading = false;
    });
  }

  void handleDismissed() async {
    // Check if more movies need to be loaded
    if (swipeCount >= movies.length - 1 && !isLoading) {
      page++;
      setState(() {
        movies.clear();
      });
      loadMovies(page);
      swipeCount = 0;
    } else {
      swipeCount++;
    }
  }

  void isMovieSaved(movieId) async {
    final isSaved = await MovieService().isMovieSaved(movieId);
    if (isSaved) {
      Navigator.of(context).pushAndRemoveUntil(MatchFoundPage.route(movieId), (route) => false);
    }
  }

  void listenToMovieChoices() {
    movieChoicesChannel = supabase.channel('public:moviechoices')
      ..on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*', // Listen to INSERT events
          schema: 'public',
          table: 'moviechoices',
        ),
        (payload, [ref]) {
          var movieId = (payload['new']['movie_id'] as double).toInt();
          isMovieSaved(movieId);
        },
      )
      ..subscribe();
  }

  void listenToFilterUpdates() {
    movieChoicesChannel = supabase.channel('public:profiles')
      ..on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*', // Listen to INSERT events
          schema: 'public',
          table: 'profiles',
        ),
        (payload, [ref]) async {
          var oldRoomId = payload['old']['room_id'] as String;
          var newRoomId = payload['new']['room_id'] as String;
          var userId = supabase.auth.currentUser!.id;
          var currentRoomId = await ProfileService().getRoomIdById(userId);
          var updateUserId = payload['new']['id'] as String;
          if (userId != updateUserId && currentRoomId == oldRoomId) {
            await ProfileService().updateProfileRoomId(newRoomId);
            setState(() {
              page = 1;
              movies.clear();
            });
            loadMovies(page);
          }
        },
      )
      ..subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Vibrant background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)], // Vibrant Tinder-like gradient
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (roomCode != null)
                  Padding(
                    padding: const EdgeInsets.all(1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Room Code: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          roomCode!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (movies.isEmpty)
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Center(
                            child: Text(
                              'No movies found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  )
                else
                  Expanded(
                    child: CardSwiper(
                      allowedSwipeDirection: AllowedSwipeDirection.only(right: true, left: true),
                      numberOfCardsDisplayed: 1,
                      cardsCount: movies.length,
                      isLoop: false,
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        final movie = movies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Movie Poster
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    movie.posterPath,
                                    fit: BoxFit.contain, // Ensures the image is fully visible
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Movie Title and Year
                              Text(
                                '${movie.title}, ${movie.releaseDate.year}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Additional Movie Info (Runtime and Ratings)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${movie.runtime} min',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.star, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${movie.voteAverage}/10',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Movie Description (Overview)
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  child: Text(
                                    movie.overview,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onSwipe: _onSwipe,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    handleDismissed();
    if (direction == CardSwiperDirection.right) {
      MovieService().saveMovie(movies[previousIndex!].id);
    }
    return true;
  }
}
