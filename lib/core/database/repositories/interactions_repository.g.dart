// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactions_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interactionsRepositoryHash() =>
    r'31e9965652ca4fa7433b310b95de8e398a9a6483';

/// See also [interactionsRepository].
@ProviderFor(interactionsRepository)
final interactionsRepositoryProvider =
    AutoDisposeProvider<InteractionsRepository>.internal(
      interactionsRepository,
      name: r'interactionsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interactionsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InteractionsRepositoryRef =
    AutoDisposeProviderRef<InteractionsRepository>;
String _$personInteractionsHash() =>
    r'3fd4cdf17a81eaf478478540056bf4a7755dac61';

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

/// See also [personInteractions].
@ProviderFor(personInteractions)
const personInteractionsProvider = PersonInteractionsFamily();

/// See also [personInteractions].
class PersonInteractionsFamily extends Family<AsyncValue<List<Interaction>>> {
  /// See also [personInteractions].
  const PersonInteractionsFamily();

  /// See also [personInteractions].
  PersonInteractionsProvider call(int personId) {
    return PersonInteractionsProvider(personId);
  }

  @override
  PersonInteractionsProvider getProviderOverride(
    covariant PersonInteractionsProvider provider,
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
  String? get name => r'personInteractionsProvider';
}

/// See also [personInteractions].
class PersonInteractionsProvider
    extends AutoDisposeStreamProvider<List<Interaction>> {
  /// See also [personInteractions].
  PersonInteractionsProvider(int personId)
    : this._internal(
        (ref) => personInteractions(ref as PersonInteractionsRef, personId),
        from: personInteractionsProvider,
        name: r'personInteractionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personInteractionsHash,
        dependencies: PersonInteractionsFamily._dependencies,
        allTransitiveDependencies:
            PersonInteractionsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonInteractionsProvider._internal(
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
    Stream<List<Interaction>> Function(PersonInteractionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonInteractionsProvider._internal(
        (ref) => create(ref as PersonInteractionsRef),
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
  AutoDisposeStreamProviderElement<List<Interaction>> createElement() {
    return _PersonInteractionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonInteractionsProvider && other.personId == personId;
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
mixin PersonInteractionsRef on AutoDisposeStreamProviderRef<List<Interaction>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PersonInteractionsProviderElement
    extends AutoDisposeStreamProviderElement<List<Interaction>>
    with PersonInteractionsRef {
  _PersonInteractionsProviderElement(super.provider);

  @override
  int get personId => (origin as PersonInteractionsProvider).personId;
}

String _$recentlyContactedPeopleHash() =>
    r'b9b91a861dec57ba0d76c6f53429790e758130a4';

/// See also [recentlyContactedPeople].
@ProviderFor(recentlyContactedPeople)
final recentlyContactedPeopleProvider =
    AutoDisposeStreamProvider<List<RecentContact>>.internal(
      recentlyContactedPeople,
      name: r'recentlyContactedPeopleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentlyContactedPeopleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentlyContactedPeopleRef =
    AutoDisposeStreamProviderRef<List<RecentContact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
