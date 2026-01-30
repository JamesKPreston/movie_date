# Movie Date

Movie Date is a Flutter mobile application that helps couples or groups find movies to watch together using a Tinder-like swiping mechanism. Set up filters for genres, release dates, and streaming services, then everyone starts swiping. When all room members swipe right on the same movie, it's a match!

## Features

### Complete
- Create a room with customizable filters (genres, release dates, actors, streaming services)
- Swipe left or right on movies with posters, descriptions, runtime, and ratings
- Real-time match notifications when all room members like the same movie
- Join existing rooms via room code
- Watch trailers directly in the app
- View streaming service availability for each movie
- Configurable match threshold (number of required matches)
- User profiles with avatars and display names
- Bottom navigation with Home, Join Room, and Search

### In Progress
- Skip and undo swipe functions
- View history of swiped movies

## Tech Stack

- **Framework**: Flutter 3.24.3 (managed via FVM)
- **Language**: Dart >=3.4.3 <4.0.0
- **State Management**: Riverpod 2.3.6 with code generation
- **Navigation**: Go Router 13.2.0
- **Backend**: Supabase (authentication, database, real-time subscriptions)
- **Movie Data**: TMDB API
- **Streaming Info**: RapidAPI (Where to Watch)

## Requirements

- Flutter SDK 3.24.3+ (or use FVM)
- Dart SDK >=3.4.3 <4.0.0
- A device or emulator (iOS/Android)
- Supabase account (for backend)
- TMDB API key
- RapidAPI key (for streaming info)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/movie_date.git
cd movie_date
```

### 2. Install Flutter (using FVM recommended)

```bash
# Install FVM if not already installed
dart pub global activate fvm

# Install the required Flutter version
fvm install 3.24.3
fvm use 3.24.3

# Or use Flutter directly (version 3.24.3+)
flutter --version
```

### 3. Set Up Environment Variables

Create a `.env` file in the project root with the following variables:

```env
API_KEY=your_tmdb_api_key
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
WHERE_TO_WATCH_API=your_rapidapi_key
```

To obtain these keys:
- **TMDB API Key**: Register at [themoviedb.org](https://www.themoviedb.org/settings/api)
- **Supabase**: Create a project at [supabase.com](https://supabase.com)
- **RapidAPI**: Subscribe to a "Where to Watch" API at [rapidapi.com](https://rapidapi.com)

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run Code Generation (if needed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

## Testing

The project has comprehensive unit tests covering models, services, and utilities.

### Run All Tests

```bash
flutter test
```

### Run Specific Test Files

```bash
# Run model tests
flutter test test/models/models_test.dart

# Run service tests
flutter test test/services/

# Run with verbose output
flutter test --reporter=expanded
```

### Test Coverage

| Component | Tests | Description |
|-----------|-------|-------------|
| Models | 17 | Profile, Room, Match, Member serialization |
| API Types | 14 | Movie, Movie2, Person fromJson/toJson |
| MovieFilters | 18 | Filter serialization with dates, persons |
| MovieService | 22 | All 8 service methods |
| RoomService | 17 | All 7 service methods |
| ConversionUtils | 12 | Movie2 to Movie conversion |
| Widgets | 37 | LoginPage, MainPage widget tests |
| **Total** | **137** | All tests passing |

## Project Structure

```
lib/
├── api/                  # TMDB API integration
│   ├── types/           # API response models (Movie, Person, Genre)
│   ├── filters/         # Query filter objects (MovieFilters)
│   └── utils/           # Enums and utilities
├── controllers/         # Riverpod state controllers
├── models/              # Data models (Profile, Room, Match, Member)
├── pages/               # UI screens (12 pages)
├── providers/           # Riverpod providers
├── repositories/        # Abstract repository interfaces
├── router/              # Go Router configuration
├── services/            # Business logic (MovieService, RoomService)
├── supabase/repositories/  # Supabase implementations
├── tmdb/repositories/   # TMDB implementations
├── utils/               # Constants, helpers
├── widgets/             # Reusable UI components
└── main.dart            # App entry point

test/
├── api/                 # API type and filter tests
├── models/              # Model serialization tests
├── pages/               # Widget tests
├── services/            # Service unit tests
└── utils/               # Utility tests
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`
The AAB will be at `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
# Build for App Store
flutter build ios --release

# Build IPA
flutter build ipa --release
```

The IPA will be at `build/ios/ipa/`

### Deployment

#### Android (Google Play Store)
1. Build the App Bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Configure release track (internal, alpha, beta, production)

#### iOS (App Store)
1. Build the archive: `flutter build ipa --release`
2. Open in Xcode: `open build/ios/archive/Runner.xcarchive`
3. Use Xcode Organizer to upload to App Store Connect

#### Fastlane (Automated)

The project includes Fastlane configurations for iOS and Android:

```bash
# iOS deployment
cd ios && fastlane beta

# Android deployment
cd android && fastlane beta
```

## Database Schema (Supabase)

The app uses the following main tables:
- `profiles` - User profiles with avatars and display names
- `rooms` - Movie rooms with filters and match thresholds
- `members` - Room membership (users in rooms)
- `movie_choices` - User swipe choices per room
- `matches` - Match tracking with count per movie

## Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes and add tests
4. Run tests to ensure they pass:
   ```bash
   flutter test
   ```
5. Commit your changes:
   ```bash
   git commit -m "Add your feature description"
   ```
6. Push and create a pull request:
   ```bash
   git push origin feature/your-feature-name
   ```

### Development Guidelines

- Follow the existing code style (enforced by `flutter_lints`)
- Add tests for new functionality
- Update `CLAUDE.md` for significant architectural changes
- Run code generation after modifying `@riverpod` providers

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or feedback, please contact us at dxsolo@gmail.com.
