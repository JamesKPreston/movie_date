import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/mock/movies_mock.dart';
import 'package:movie_date/pages/main_page.dart';
import 'package:movie_date/providers/tmdb/genre_repository_provider.dart';
import 'package:movie_date/providers/movie_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SwipePageTutorial extends ConsumerStatefulWidget {
  const SwipePageTutorial({super.key});

  @override
  ConsumerState<SwipePageTutorial> createState() => _SwipePageState();
}

class _SwipePageState extends ConsumerState<SwipePageTutorial> {
  List<Movie> movies = [];
  String movieGenres = '';
  int page = 1;
  bool isLoading = false;
  String? roomCode;
  RealtimeChannel? movieChoicesChannel;
  int swipeCount = 0;
  String overlayText =
      'Swipe left to say "no" and swipe right to say "yes". Swiping right adds the movie to your list of want to watch. When someone else also swipes right, a match will be shown.';

  int nextPressCount = 0;

  void updateOverlayText(String text, StepWidgetParams params) {
    setState(() {
      overlayText = text;
      nextPressCount++;
      if (nextPressCount >= 2) {
        params.onNext!();
        nextPressCount = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovies(page);
  }

  Future<void> _markTutorialAsSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadMovies(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    var result = MoviesMock.getMovies();
    await setGenres(result.first.genreIds);

    setState(() {
      movies.addAll(result);
      isLoading = false;
    });
  }

  Future<void> setGenres(List<int> genreIds) async {
    var genreRepo = ref.read(genreRepositoryProvider);
    final genres = await genreRepo.getGenreNames(genreIds);
    setState(() {
      movieGenres = genres;
    });
  }

  void handleDismissed() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntroStepBuilder(
                      order: 6,
                      text: '',
                      overlayBuilder: (params) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "If you create a room by using the filters, you can share this room code with another user to have them join your room",
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 8),
                                      IntroButton(
                                        onPressed: () async {
                                          await _markTutorialAsSeen();
                                          params.onFinish();
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MainPage.route(),
                                            (route) => false,
                                          );
                                        },
                                        text: 'Finish',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      builder: (context, key) => Text('Room Code: 123456',
                          style: const TextStyle(fontSize: 18, color: Colors.white), key: key)),
                ),
                Expanded(
                  child: IntroStepBuilder(
                    order: 4,
                    getOverlayPosition: ({
                      required Offset offset,
                      required Size screenSize,
                      required Size size,
                    }) {
                      return OverlayPosition(
                        top: screenSize.height / 2,
                        left: 16,
                        width: screenSize.width - 32,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      );
                    },
                    overlayBuilder: (params) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  overlayText,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IntroButton(
                                      onPressed: params.onPrev,
                                      text: 'Prev',
                                    ),
                                    const SizedBox(width: 8),
                                    IntroButton(
                                      onPressed: () {
                                        _markTutorialAsSeen();
                                        setState(() {
                                          if (nextPressCount == 0) {
                                            overlayText = "Tap on the poster to see the full description and a trailer";
                                            nextPressCount++;
                                          } else {
                                            params.onNext?.call();
                                            nextPressCount = 0;
                                          }
                                        });
                                      },
                                      text: 'Next',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },

                    // onHighlightWidgetTap: handleDismissed,
                    builder: (context, key) => movies.isEmpty
                        ? Center(
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'No movies found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          )
                        : CardSwiper(
                            key: key,
                            cardsCount: movies.length,
                            isLoop: true,
                            numberOfCardsDisplayed: movies.length < 3 ? movies.length : 3,
                            allowedSwipeDirection: AllowedSwipeDirection.only(right: true, left: true),
                            cardBuilder: (context, index, percentThresholdX, __) {
                              final movie = movies[index];
                              String? overlayText;
                              Color? overlayColor;

                              if (percentThresholdX < -0.2) {
                                overlayText = "Don't Watch";
                                overlayColor = Colors.red;
                              } else if (percentThresholdX > 0.2) {
                                overlayText = "Watch Movie";
                                overlayColor = Colors.green;
                              }

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    movie.posterPath,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    right: 20,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${movie.title}, ${movie.releaseDate.year}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${movieGenres}',
                                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${movie.runtime} min  |  ${movie.voteAverage}/10',
                                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          movie.overview,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (overlayText != null)
                                    Center(
                                      child: Text(
                                        overlayText,
                                        style: TextStyle(
                                          fontSize: 48,
                                          color: overlayColor,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10.0,
                                              color: Colors.black,
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                            onSwipe: (previousIndex, currentIndex, direction) {
                              handleDismissed();
                              if (currentIndex != null && movies.length > 0) {
                                setGenres(movies[currentIndex].genreIds);
                              }

                              if (direction == CardSwiperDirection.right) {
                                final movieService = ref.read(movieServiceProvider);
                                movieService.saveMovie(movies[previousIndex].id);
                              }
                              return true;
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
          label: 'Home',
          icon: IntroStepBuilder(
            order: 1,
            text: "Pressing the home icon takes you to the movie swipe page",
            onWidgetLoad: () {
              Intro.of(context).start();
            },
            padding: EdgeInsets.fromLTRB(10, 5, 10, 20),
            builder: (context, key) => Icon(
              Icons.home,
              key: key,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'Join Room',
          icon: IntroStepBuilder(
            order: 2,
            text: "Press join room and enter the room code given to you from another user",
            padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
            builder: (context, key) => Icon(
              Icons.door_front_door_outlined,
              key: key,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'Filters',
          icon: IntroStepBuilder(
            order: 3,
            text: "Press filters to search for movies based on genre, actors, and runtime",
            padding: EdgeInsets.fromLTRB(10, 5, 10, 20),
            builder: (context, key) => Icon(
              Icons.filter_b_and_w_outlined,
              key: key,
            ),
          ),
        ),
      ]),
    );
  }
}
