// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_connections_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$personConnectionsRepositoryHash() =>
    r'2add4915d391e31d5591f5a14bc9b0a90d2a1c84';

/// See also [personConnectionsRepository].
@ProviderFor(personConnectionsRepository)
final personConnectionsRepositoryProvider =
    AutoDisposeProvider<PersonConnectionsRepository>.internal(
      personConnectionsRepository,
      name: r'personConnectionsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personConnectionsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonConnectionsRepositoryRef =
    AutoDisposeProviderRef<PersonConnectionsRepository>;
String _$personConnectionsHash() => r'4c1d68bb5183923c48c32e66488c024cdc917a11';

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

/// See also [personConnections].
@ProviderFor(personConnections)
const personConnectionsProvider = PersonConnectionsFamily();

/// See also [personConnections].
class PersonConnectionsFamily
    extends Family<AsyncValue<List<PersonConnection>>> {
  /// See also [personConnections].
  const PersonConnectionsFamily();

  /// See also [personConnections].
  PersonConnectionsProvider call(int personId) {
    return PersonConnectionsProvider(personId);
  }

  @override
  PersonConnectionsProvider getProviderOverride(
    covariant PersonConnectionsProvider provider,
  ) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personConnectionsProvider';
}

/// See also [personConnections].
class PersonConnectionsProvider
    extends AutoDisposeStreamProvider<List<PersonConnection>> {
  /// See also [personConnections].
  PersonConnectionsProvider(int personId)
    : this._internal(
        (ref) => personConnections(ref as PersonConnectionsRef, personId),
        from: personConnectionsProvider,
        name: r'personConnectionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personConnectionsHash,
        dependencies: PersonConnectionsFamily._dependencies,
        allTransitiveDependencies:
            PersonConnectionsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonConnectionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final int personId;

  @override
  Override overrideWith(
    Stream<List<PersonConnection>> Function(PersonConnectionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonConnectionsProvider._internal(
        (ref) => create(ref as PersonConnectionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PersonConnection>> createElement() {
    return _PersonConnectionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonConnectionsProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonConnectionsRef
    on AutoDisposeStreamProviderRef<List<PersonConnection>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PersonConnectionsProviderElement
    extends AutoDisposeStreamProviderElement<List<PersonConnection>>
    with PersonConnectionsRef {
  _PersonConnectionsProviderElement(super.provider);

  @override
  int get personId => (origin as PersonConnectionsProvider).personId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
