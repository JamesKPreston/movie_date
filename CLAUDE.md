# CLAUDE.md - Movie Date App Development Guide

This file provides guidance for AI assistants (like Claude) working on this codebase.

## Project Overview

Movie Date is a Flutter mobile app that helps couples/groups find movies to watch together using a Tinder-like swiping mechanism. When all room members swipe right on the same movie, it's a match!

## Tech Stack

- **Framework**: Flutter 3.24.3 (managed via FVM)
- **Language**: Dart >=3.4.3 <4.0.0
- **State Management**: Riverpod 2.3.6 with code generation
- **Navigation**: Go Router 13.2.0
- **Backend**: Supabase (auth, database, real-time)
- **Movie Data**: TMDB API
- **Streaming Info**: RapidAPI (Where to Watch)

## Project Structure

```
lib/
├── api/                  # TMDB API integration
│   ├── types/           # API response models (Movie, Person, Genre)
│   ├── filters/         # Query filter objects (MovieFilters)
│   ├── utils/           # Enums and utilities
│   ├── discover.dart    # TMDB discover endpoint
│   └── api.dart         # Dio HTTP client
├── controllers/         # Riverpod state controllers (AuthController)
├── models/              # Data models (Profile, Room, Match, Member)
├── pages/               # UI screens (12 pages)
├── providers/           # Riverpod providers (dependency injection)
├── repositories/        # Abstract repository interfaces
├── router/              # Go Router configuration
├── services/            # Business logic (MovieService, RoomService)
├── supabase/
│   └── repositories/    # Supabase repository implementations
├── tmdb/
│   ├── repositories/    # TMDB repository implementations
│   └── providers/       # TMDB-specific providers
├── utils/               # Constants, helpers
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

## Architecture Pattern

**Clean Architecture with Repository Pattern + Service Layer**

```
UI Layer (pages/, widgets/)
    ↓ uses
Service Layer (services/)
    ↓ orchestrates
Repository Layer (repositories/, supabase/repositories/, tmdb/repositories/)
    ↓ calls
API Layer (api/, Supabase client)
```

## Key Concepts

### State Management (Riverpod)

Uses `riverpod_generator` for code generation. After modifying providers, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Provider patterns used:**
- `@riverpod` function providers for simple factories
- `@riverpod` class providers for stateful async logic
- Stream providers for real-time Supabase subscriptions

**Consumer patterns:**
- `ConsumerWidget` - stateless with Riverpod access
- `ConsumerStatefulWidget` - stateful with Riverpod access
- `ref.watch()` - reactive state observation
- `ref.read()` - one-time read
- `ref.listen()` - side effects on state changes

### Navigation (Go Router)

Routes defined in `lib/router/router.dart`. Key routes:
- `/login` - Authentication
- `/` (home) - Main page with bottom navigation
- `/match_found` - Match result (receives movieId via `extra`)
- `/tutorial` - First-time user tutorial
- `/settings` - App settings

Navigation uses named routes: `context.goNamed('route_name', extra: data)`

### Data Flow

1. **UI** calls service methods via providers
2. **Services** orchestrate repository calls
3. **Repositories** interact with APIs/Supabase
4. **Real-time** updates via Supabase channels (matchChannelProvider, filtersChannelProvider)

## Common Tasks

### Adding a New Feature

1. **Model** (`lib/models/`): Create data class with `fromMap`/`toJson`
2. **Repository interface** (`lib/repositories/`): Define abstract methods
3. **Repository implementation** (`lib/supabase/repositories/`): Implement for Supabase
4. **Provider** (`lib/providers/`): Create `@riverpod` provider
5. **Service method** (if needed): Add to appropriate service
6. **Page/Widget** (`lib/pages/` or `lib/widgets/`): Create UI
7. **Route** (`lib/router/router.dart`): Add GoRoute
8. **Generate**: Run `flutter pub run build_runner build`

### Adding a New Page

```dart
// lib/pages/my_new_page.dart
class MyNewPage extends ConsumerWidget {
  const MyNewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access providers with ref.watch() or ref.read()
    return Scaffold(
      appBar: AppBar(title: Text('My Page')),
      body: // ...
    );
  }
}
```

Then add to router:
```dart
GoRoute(
  name: 'mypage',
  path: '/mypage',
  builder: (context, state) => const MyNewPage(),
)
```

### Working with Supabase

```dart
// Read data
final result = await Supabase.instance.client
    .from('table_name')
    .select()
    .eq('column', value);

// Insert data
await Supabase.instance.client
    .from('table_name')
    .insert({'column': value});

// Real-time subscription (see providers/match_channel_provider.dart)
```

## Environment Setup

Required environment variables in `.env`:
- `API_KEY` - TMDB API key
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `WHERE_TO_WATCH_API` - RapidAPI key

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Supabase init, ProviderScope |
| `lib/router/router.dart` | Navigation, auth guards |
| `lib/controllers/auth_controller.dart` | Auth state (login/logout) |
| `lib/services/movie_service.dart` | Movie operations |
| `lib/services/room_service.dart` | Room management |
| `lib/pages/swipe_page.dart` | Main swiping UI |
| `lib/pages/main_page.dart` | Home with bottom nav |
| `lib/pages/room_page.dart` | Filters configuration |
| `lib/utils/constants.dart` | Theme, streaming services list |

## Coding Conventions

- **Linting**: Uses `flutter_lints`
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Widgets**: One widget per file, use `const` constructors
- **Error handling**: Try-catch with SnackBar for user feedback
- **Async**: Use `async/await`, handle loading states with `AsyncValue`

## Testing

Tests are in `/test/`. Run with:
```bash
flutter test
```

Current coverage is minimal. When adding tests:
- Unit tests for repositories (mock Supabase)
- Widget tests for pages (mock providers with `ProviderScope.overrides`)

## Dependencies to Know

- `flutter_card_swiper` - Tinder-like card swiping
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `supabase_flutter` - Backend
- `dio` - HTTP client for TMDB
- `flutter_dotenv` - Environment variables

## Common Issues

1. **Provider not updating**: Make sure to use `ref.watch()` not `ref.read()` for reactive updates
2. **Code generation out of date**: Run `flutter pub run build_runner build`
3. **Supabase auth issues**: Check if user session is valid via `Supabase.instance.client.auth.currentUser`
4. **Missing .env**: Copy `.env.example` to `.env` and fill in values

## Useful Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (after modifying @riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Generate app icons
flutter pub run flutter_launcher_icons

# Check Flutter version (should match .fvmrc)
flutter --version
```
