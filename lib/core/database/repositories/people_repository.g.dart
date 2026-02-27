// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$peopleRepositoryHash() => r'f4dc45d62fc7764c18c78b411ef8a749e0636c26';

/// See also [peopleRepository].
@ProviderFor(peopleRepository)
final peopleRepositoryProvider = AutoDisposeProvider<PeopleRepository>.internal(
  peopleRepository,
  name: r'peopleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$peopleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PeopleRepositoryRef = AutoDisposeProviderRef<PeopleRepository>;
String _$allPeopleHash() => r'1e6964d953b454733da45a7fb68cee7fac452f6b';

/// See also [allPeople].
@ProviderFor(allPeople)
final allPeopleProvider = AutoDisposeStreamProvider<List<Person>>.internal(
  allPeople,
  name: r'allPeopleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allPeopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllPeopleRef = AutoDisposeStreamProviderRef<List<Person>>;
String _$personStreamHash() => r'090ff92f9a0622f9326ba467d3d384f552a6b516';

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

/// See also [personStream].
@ProviderFor(personStream)
const personStreamProvider = PersonStreamFamily();

/// See also [personStream].
class PersonStreamFamily extends Family<AsyncValue<Person>> {
  /// See also [personStream].
  const PersonStreamFamily();

  /// See also [personStream].
  PersonStreamProvider call(int personId) {
    return PersonStreamProvider(personId);
  }

  @override
  PersonStreamProvider getProviderOverride(
    covariant PersonStreamProvider provider,
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
  String? get name => r'personStreamProvider';
}

/// See also [personStream].
class PersonStreamProvider extends AutoDisposeStreamProvider<Person> {
  /// See also [personStream].
  PersonStreamProvider(int personId)
    : this._internal(
        (ref) => personStream(ref as PersonStreamRef, personId),
        from: personStreamProvider,
        name: r'personStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personStreamHash,
        dependencies: PersonStreamFamily._dependencies,
        allTransitiveDependencies:
            PersonStreamFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonStreamProvider._internal(
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
    Stream<Person> Function(PersonStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonStreamProvider._internal(
        (ref) => create(ref as PersonStreamRef),
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
  AutoDisposeStreamProviderElement<Person> createElement() {
    return _PersonStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonStreamProvider && other.personId == personId;
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
mixin PersonStreamRef on AutoDisposeStreamProviderRef<Person> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PersonStreamProviderElement
    extends AutoDisposeStreamProviderElement<Person>
    with PersonStreamRef {
  _PersonStreamProviderElement(super.provider);

  @override
  int get personId => (origin as PersonStreamProvider).personId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
