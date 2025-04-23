import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/mock/movies_mock.dart';
import 'package:movie_date/tmdb/providers/genre_repository_provider.dart';
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFFF3868), Color(0xFFFFB49A)],
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
                                    "You can share this room code with another user to have them join your room",
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
                                          context.goNamed('home');
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
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold), key: key)),
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
                                ? CircularProgressIndicator(color: Colors.white)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.movie_outlined, size: 70, color: Colors.white70),
                                      SizedBox(height: 16),
                                      Text(
                                        'No movies found',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CardSwiper(
                              key: key,
                              cardsCount: movies.length,
                              isLoop: true,
                              numberOfCardsDisplayed: movies.length < 3 ? movies.length : 3,
                              backCardOffset: Offset(0, 40),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              allowedSwipeDirection: AllowedSwipeDirection.only(right: true, left: true),
                              cardBuilder: (context, index, percentThresholdX, __) {
                                final movie = movies[index];
                                String? overlayText;
                                Color? overlayColor;

                                if (percentThresholdX < -0.2) {
                                  overlayText = "NOPE";
                                  overlayColor = Colors.red;
                                } else if (percentThresholdX > 0.2) {
                                  overlayText = "LIKE";
                                  overlayColor = Colors.green;
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          movie.posterPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[800],
                                              child: Center(
                                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                                              ),
                                            ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              stops: [0.0, 0.3, 0.7, 1.0],
                                            ),
                                          ),
                                        ),
                                        if (overlayText != null)
                                          Positioned(
                                            top: 50,
                                            left: overlayText == "NOPE" ? 20 : null,
                                            right: overlayText == "LIKE" ? 20 : null,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: overlayColor!,
                                                  width: 4,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                overlayText,
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  color: overlayColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${movie.title}',
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${movie.releaseDate.year}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${movie.voteAverage}/10',
                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Icon(Icons.access_time, color: Colors.white70, size: 18),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${movie.runtime} min',
                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                movie.overview,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 14, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  onTap: () {},
                  icon: Icons.close,
                  color: Colors.white,
                  backgroundColor: Colors.red,
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  onTap: () {},
                  icon: Icons.favorite,
                  color: Colors.white,
                  backgroundColor: Colors.green,
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
          label: 'Search',
          icon: IntroStepBuilder(
            order: 3,
            text: "Press to search for movies based on genre, actors, and runtime",
            padding: EdgeInsets.fromLTRB(10, 5, 10, 20),
            builder: (context, key) => Icon(
              Icons.search_outlined,
              key: key,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}