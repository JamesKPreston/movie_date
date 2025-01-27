import 'dart:ffi';

import 'package:movie_date/api/types/person.dart';

class MovieFilters {
  // Existing properties
  String? certification;
  String? certificationGte;
  String? certificationLte;
  String? certificationCountry;
  bool? includeAdult = false;
  bool? includeVideo = false;
  String? language = 'en';
  int? page = 1;
  DateTime? primaryReleaseDateYear;
  DateTime? primaryReleaseDateGte;
  DateTime? primaryReleaseDateLte;
  String? region;
  DateTime? releaseDateGte;
  DateTime? releaseDateLte;
  String? sortBy = 'popularity.desc';
  Float? voteAverageGte;
  Float? voteAverageLte;
  Float? voteCountGte;
  Float? voteCountLte;
  String? watchRegion;
  String? withCast;
  String? withCompanies;
  String? withCrew;
  String? withGenres;
  String? withKeywords;
  String? withOriginalLanguage;
  String? withOriginCountry;
  String? withPeople;
  int? withReleaseType;
  int? withRuntimeGte;
  int? withRuntimeLte;
  String? withWatchMonetizationTypes;
  String? withWatchProviders;
  String? withoutGenres;
  String? withoutKeywords;
  String? withoutPeople;
  String? withoutCompanies;
  String? withoutWatchProviders;
  int? year;

  // New property
  List<Person>? persons;

  MovieFilters(
      {this.page,
      this.language,
      this.primaryReleaseDateGte,
      this.primaryReleaseDateLte,
      this.withGenres,
      this.withCast,
      this.persons,
      this.watchRegion,
      this.withWatchProviders});

  // Updated fromMap to include List<Person>
  factory MovieFilters.fromMap(Map<String, dynamic> map) {
    return MovieFilters(
      page: map['page'] as int?,
      language: map['language'] as String?,
      primaryReleaseDateGte:
          map['primaryReleaseDateGte'] != null ? DateTime.parse(map['primaryReleaseDateGte'] as String) : null,
      primaryReleaseDateLte:
          map['primaryReleaseDateLte'] != null ? DateTime.parse(map['primaryReleaseDateLte'] as String) : null,
      withGenres: map['withGenres'] as String?,
      withCast: map['withCast'] as String?,
      withWatchProviders: map['withWatchProviders'] as String?,
      watchRegion: map['watchRegion'] as String?,
      persons: map['persons'] != null
          ? (map['persons'] as List).map((person) => Person.fromJson(person as Map<String, dynamic>)).toList()
          : null,
    );
  }

  // Updated toMap to include List<Person>
  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'language': language,
      if (primaryReleaseDateGte != null) 'primaryReleaseDateGte': primaryReleaseDateGte?.toIso8601String(),
      if (primaryReleaseDateLte != null) 'primaryReleaseDateLte': primaryReleaseDateLte?.toIso8601String(),
      if (withGenres != null) 'withGenres': withGenres,
      if (withCast != null) 'withCast': withCast,
      if (withWatchProviders != null) 'withWatchProviders': withWatchProviders,
      if (watchRegion != null) 'watchRegion': watchRegion,
      if (persons != null)
        'persons': persons
            ?.map((person) => {
                  'adult': person.adult,
                  'gender': person.gender,
                  'id': person.id,
                  'known_for_department': person.knownForDepartment,
                  'name': person.name,
                  'original_name': person.originalName,
                  'popularity': person.popularity,
                  'profile_path': person.profilePath,
                })
            .toList(),
    };
  }
}
