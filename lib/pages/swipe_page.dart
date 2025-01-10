import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jp_moviedb/types/movie.dart';
import 'package:movie_date/pages/match_found_page.dart';
import 'package:movie_date/supabase/providers/filters_channel_provider.dart';
import 'package:movie_date/tmdb/providers/genre_repository_provider.dart';
import 'package:movie_date/supabase/providers/movie_choices_channel_provider.dart';
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
    setState(() {});
  }

  void loadMovies(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final movieService = await ref.read(movieServiceProvider);
    var result = await movieService.getMovies(page);
    if (result.length > 0) {
      await setGenres(result.first.genreIds);
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
    final isSaved = await movieService.isMovieSaved(movieId);
    if (isSaved) {
      Navigator.of(context).pushAndRemoveUntil(MatchFoundPage.route(movieId), (route) => false);
    }
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
    ref.listen(movieChoicesChannelProvider, (previous, next) {
      next.when(
        data: (movieIds) {
          if (movieIds.isNotEmpty) {
            // Avoid multiple navigations by checking a flag
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MatchFoundPage.route(movieIds.first),
                (route) => false,
              );
            });
          }
        },
        loading: () {}, // Handle loading state if needed
        error: (error, stackTrace) {
          print('Error loading movie choices: $error');
        },
      );
    });

    // Listen for filter updates and reload movies if needed
    ref.listen(filtersChannelProvider, (previous, next) {
      next.when(
        data: (filters) {
          // if (filters.id != 'blank') {
          // Refresh page with new filters
          loadMovies(1);
          // }
        },
        loading: () {}, // Handle loading state if needed
        error: (error, stackTrace) {
          print('Error loading filters: $error');
        },
      );
    });

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
                if (roomCode != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Room Code: $roomCode',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                Expanded(
                  child: movies.isEmpty
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
                            return GestureDetector(
                              onTap: () => showMovieDetails(context, movie),
                              child: Stack(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
