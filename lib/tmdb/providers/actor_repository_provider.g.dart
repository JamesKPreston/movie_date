// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$actorRepositoryHash() => r'7164f3be124693c1117b6031556969de0c27510c';

/// See also [actorRepository].
@ProviderFor(actorRepository)
final actorRepositoryProvider = AutoDisposeProvider<ActorRepository>.internal(
  actorRepository,
  name: r'actorRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$actorRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActorRepositoryRef = AutoDisposeProviderRef<ActorRepository>;
String _$actorFutureHash() => r'd6bd9cce3b178ad517b8f2dccf7ccc9b91d20d8e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [actorFuture].
@ProviderFor(actorFuture)
const actorFutureProvider = ActorFutureFamily();

/// See also [actorFuture].
class ActorFutureFamily extends Family<AsyncValue<List<Person>>> {
  /// See also [actorFuture].
  const ActorFutureFamily();

  /// See also [actorFuture].
  ActorFutureProvider call(
    String actors,
  ) {
    return ActorFutureProvider(
      actors,
    );
  }

  @override
  ActorFutureProvider getProviderOverride(
    covariant ActorFutureProvider provider,
  ) {
    return call(
      provider.actors,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'actorFutureProvider';
}

/// See also [actorFuture].
class ActorFutureProvider extends AutoDisposeFutureProvider<List<Person>> {
  /// See also [actorFuture].
  ActorFutureProvider(
    String actors,
  ) : this._internal(
          (ref) => actorFuture(
            ref as ActorFutureRef,
            actors,
          ),
          from: actorFutureProvider,
          name: r'actorFutureProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$actorFutureHash,
          dependencies: ActorFutureFamily._dependencies,
          allTransitiveDependencies:
              ActorFutureFamily._allTransitiveDependencies,
          actors: actors,
        );

  ActorFutureProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.actors,
  }) : super.internal();

  final String actors;

  @override
  Override overrideWith(
    FutureOr<List<Person>> Function(ActorFutureRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActorFutureProvider._internal(
        (ref) => create(ref as ActorFutureRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        actors: actors,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Person>> createElement() {
    return _ActorFutureProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorFutureProvider && other.actors == actors;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, actors.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActorFutureRef on AutoDisposeFutureProviderRef<List<Person>> {
  /// The parameter `actors` of this provider.
  String get actors;
}

class _ActorFutureProviderElement
    extends AutoDisposeFutureProviderElement<List<Person>> with ActorFutureRef {
  _ActorFutureProviderElement(super.provider);

  @override
  String get actors => (origin as ActorFutureProvider).actors;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
