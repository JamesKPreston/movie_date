import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/restaurant_repository.dart';
import '../models/restaurant.dart';

final restaurantRepositoryProvider = Provider((ref) => RestaurantRepository());

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getRestaurants();
}); 