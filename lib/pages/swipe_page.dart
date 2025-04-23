import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/api/types/movie.dart';
import 'package:movie_date/providers/filters_channel_provider.dart';
import 'package:movie_date/providers/match_channel_provider.dart';
import 'package:movie_date/providers/match_repository_provider.dart';
import 'package:movie_date/tmdb/providers/genre_repository_provider.dart';
import 'package:movie_date/providers/movie_service_provider.dart';
import 'package:movie_date/providers/profile_repository_provider.dart';
import 'package:movie_date/providers/room_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_date/widgets/movie_details_widget.dart';
import 'package:movie_date/providers/youtube_repository_provider.dart';

class SwipePage extends ConsumerStatefulWidget {
  const SwipePage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SwipePage());
  }

  @override
  ConsumerState<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends ConsumerState<SwipePage> {
  List<Movie> movies = [];
  String movieGenres = '';
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
  }

  @override
  void dispose() {
    movieChoicesChannel?.unsubscribe();
    super.dispose();
  }

  void loadRoomCode() async {
    final roomService = ref.read(roomServiceProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final userId = await profileRepo.getCurrentUserId();
    roomCode = await roomService.getRoomCodeById(userId);
    //setState(() {});
  }

  void loadMovies(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final movieService = await ref.read(movieServiceProvider);
    //var result = await movieService.getMoviesByStreamingService('netflix');

    var result = await movieService.getMovies(page);
    if (result.length > 0) {
      // await setGenres(result.first.genreIds);
      //if this is the first page then
      //it is the first time this screen is loaded
      //perhaps from when the user closed and reopened the app
      //so we need to check if there is a match because the app
      //was closed so the realtime monitoring was not active
      if (page == 1) {
        movies.clear();
        var movieId = await movieService.findMatchingMovieId();
        if (movieId > 0) {
          isMovieSaved(movieId);
        }
      }
    }

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

  void checkMatches() async {
    var profileRepo = ref.read(profileRepositoryProvider);
    var matchRepo = ref.read(matchRepositoryProvider);
    var roomService = ref.read(roomServiceProvider);
    var userId = await profileRepo.getCurrentUserId();
    var room = await roomService.getRoomByUserId(userId);
    var matches = await matchRepo.getMatchesByRoom(room.id);

    for (var match in matches) {
      if (match.match_count >= room.match_threshold) {
        context.goNamed(
          'match_found',
          extra: match.movie_id,
        );
      }
    }
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

  void isMovieSaved(movieId) async {
    final movieService = ref.read(movieServiceProvider);
    await movieService.isMovieSaved(movieId);
  }

  Future<void> showMovieDetails(BuildContext context, Movie movie) async {
    var youtube = ref.read(youTubeRepositoryProvider);
    String movieId = await youtube.searchMovieTrailers('${movie.title} ${movie.releaseDate.year}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MovieDetailsWidget(movie: movie, genres: movieGenres, trailerId: movieId),
    );
  }

  @override
  Widget build(BuildContext context) {
    checkMatches();
    ref.listen(matchChannelProvider, (previous, next) {
      next.when(
        data: (movieIds) {
          if (movieIds.isNotEmpty) {
            var movieId = movieIds.first;
            movieIds.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed(
                'match_found',
                extra: movieId,
              );
            });
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          print('Error loading movie choices: $error');
        },
      );
      setState(() {});
      // matchChannelHandler(context, next);
    });

    ref.listen(filtersChannelProvider, (previous, next) {
      next.when(
        data: (filters) {
          loadMovies(1);
        },
        loading: () {},
        error: (error, stackTrace) {
          print('Error loading filters: $error');
        },
      );
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: roomCode != null
          ? Text('Room Code: $roomCode',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
          : null,
        centerTitle: true,
      ),
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
                Expanded(
                  child: movies.isEmpty
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

                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => MovieDetailsWidget(movie: movie),
                                );
                              },
                              child: Container(
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
                  onTap: () {
                    if (movies.isNotEmpty) {
                      final controller = CardSwiperController();
                      controller.swipeLeft();
                    }
                  },
                  icon: Icons.close,
                  color: Colors.white,
                  backgroundColor: Colors.red,
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  onTap: () {
                    if (movies.isNotEmpty) {
                      final controller = CardSwiperController();
                      controller.swipeRight();
                    }
                  },
                  icon: Icons.favorite,
                  color: Colors.white,
                  backgroundColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
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