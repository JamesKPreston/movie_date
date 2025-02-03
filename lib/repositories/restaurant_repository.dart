import '../models/restaurant.dart';

class RestaurantRepository {
  // Mock data method
  Future<List<Restaurant>> getRestaurants() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data
    return [
      Restaurant(
        id: '1',
        name: 'La Belle Vie',
        imageUrl: 'https://picsum.photos/seed/restaurant1/400/300',
        cuisine: 'French',
        rating: 4.5,
        address: '123 Gourmet Street',
        priceLevel: '\$\$\$',
      ),
      Restaurant(
        id: '2',
        name: 'Sushi Master',
        imageUrl: 'https://picsum.photos/seed/restaurant2/400/300',
        cuisine: 'Japanese',
        rating: 4.8,
        address: '456 Ocean Avenue',
        priceLevel: '\$\$',
      ),
      Restaurant(
        id: '3',
        name: 'Mama Mia',
        imageUrl: 'https://picsum.photos/seed/restaurant3/400/300',
        cuisine: 'Italian',
        rating: 4.3,
        address: '789 Pasta Lane',
        priceLevel: '\$\$',
      ),
    ];
  }
} 