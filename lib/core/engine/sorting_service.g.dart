// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorting_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sortedPeopleHash() => r'16ba508e3eff46cf7c2c02aac934d06028447310';

/// See also [sortedPeople].
@ProviderFor(sortedPeople)
final sortedPeopleProvider = AutoDisposeStreamProvider<List<Person>>.internal(
  sortedPeople,
  name: r'sortedPeopleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sortedPeopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortedPeopleRef = AutoDisposeStreamProviderRef<List<Person>>;
String _$sortOrderHash() => r'7b6855eb6abf9f3f8e12c9218f5099006bf8d4f0';

/// See also [SortOrder].
@ProviderFor(SortOrder)
final sortOrderProvider =
    AutoDisposeNotifierProvider<SortOrder, PersonSortOrder>.internal(
      SortOrder.new,
      name: r'sortOrderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sortOrderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SortOrder = AutoDisposeNotifier<PersonSortOrder>;
String _$sortingServiceHash() => r'8291603ed1bb588353ab39c189e7504f42cda04d';

/// See also [SortingService].
@ProviderFor(SortingService)
final sortingServiceProvider =
    AutoDisposeNotifierProvider<SortingService, void>.internal(
      SortingService.new,
      name: r'sortingServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sortingServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SortingService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
