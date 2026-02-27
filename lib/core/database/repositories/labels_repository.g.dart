// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labels_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$labelsRepositoryHash() => r'0f91b7cd30282dde8902cd8a757f2caea70e5a00';

/// See also [labelsRepository].
@ProviderFor(labelsRepository)
final labelsRepositoryProvider = AutoDisposeProvider<LabelsRepository>.internal(
  labelsRepository,
  name: r'labelsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$labelsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LabelsRepositoryRef = AutoDisposeProviderRef<LabelsRepository>;
String _$allLabelsHash() => r'bbaf50b721e3e33de8926a80a1c00cae56501395';

/// See also [allLabels].
@ProviderFor(allLabels)
final allLabelsProvider = AutoDisposeStreamProvider<List<Label>>.internal(
  allLabels,
  name: r'allLabelsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allLabelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllLabelsRef = AutoDisposeStreamProviderRef<List<Label>>;
String _$labelsForPersonHash() => r'c06041e563de71abc14bf77bbe141dfdc7816c55';

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

/// See also [labelsForPerson].
@ProviderFor(labelsForPerson)
const labelsForPersonProvider = LabelsForPersonFamily();

/// See also [labelsForPerson].
class LabelsForPersonFamily extends Family<AsyncValue<List<Label>>> {
  /// See also [labelsForPerson].
  const LabelsForPersonFamily();

  /// See also [labelsForPerson].
  LabelsForPersonProvider call(int personId) {
    return LabelsForPersonProvider(personId);
  }

  @override
  LabelsForPersonProvider getProviderOverride(
    covariant LabelsForPersonProvider provider,
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
  String? get name => r'labelsForPersonProvider';
}

/// See also [labelsForPerson].
class LabelsForPersonProvider extends AutoDisposeStreamProvider<List<Label>> {
  /// See also [labelsForPerson].
  LabelsForPersonProvider(int personId)
    : this._internal(
        (ref) => labelsForPerson(ref as LabelsForPersonRef, personId),
        from: labelsForPersonProvider,
        name: r'labelsForPersonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$labelsForPersonHash,
        dependencies: LabelsForPersonFamily._dependencies,
        allTransitiveDependencies:
            LabelsForPersonFamily._allTransitiveDependencies,
        personId: personId,
      );

  LabelsForPersonProvider._internal(
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
    Stream<List<Label>> Function(LabelsForPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LabelsForPersonProvider._internal(
        (ref) => create(ref as LabelsForPersonRef),
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
  AutoDisposeStreamProviderElement<List<Label>> createElement() {
    return _LabelsForPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LabelsForPersonProvider && other.personId == personId;
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
mixin LabelsForPersonRef on AutoDisposeStreamProviderRef<List<Label>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _LabelsForPersonProviderElement
    extends AutoDisposeStreamProviderElement<List<Label>>
    with LabelsForPersonRef {
  _LabelsForPersonProviderElement(super.provider);

  @override
  int get personId => (origin as LabelsForPersonProvider).personId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
