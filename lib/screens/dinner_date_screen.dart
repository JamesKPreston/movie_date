import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../providers/restaurant_provider.dart';

class DinnerDateScreen extends ConsumerWidget {
  const DinnerDateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinner Date'),
      ),
      body: restaurantsAsync.when(
        data: (restaurants) {
          return CardSwiper(
            cardsCount: restaurants.length,
            cardBuilder: (context, index, _, __) {
              final restaurant = restaurants[index];
              return Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('${restaurant.cuisine} • ${restaurant.priceLevel}'),
                          const SizedBox(height: 4),
                          Text('Rating: ${restaurant.rating}'),
                          const SizedBox(height: 4),
                          Text(restaurant.address),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
} 