import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../database/repositories/people_repository.dart';
import 'health_score_engine.dart';

part 'sorting_service.g.dart';

enum PersonSortOrder {
  mostOverdue('Most Overdue'),
  lowestHealth('Lowest Health'),
  highestPriority('Highest Priority'),
  recentlyContacted('Recently Contacted'),
  alphabetical('Alphabetical');

  final String label;
  const PersonSortOrder(this.label);
}

@riverpod
class SortOrder extends _$SortOrder {
  @override
  PersonSortOrder build() => PersonSortOrder.mostOverdue;

  void setOrder(PersonSortOrder order) => state = order;
}

@riverpod
class SortingService extends _$SortingService {
  @override
  void build() {}

  List<Person> sort(
    List<Person> people,
    HealthScoreEngine engine,
    PersonSortOrder order,
  ) {
    final list = List<Person>.from(people);

    switch (order) {
      case PersonSortOrder.mostOverdue:
        list.sort((a, b) {
          final statusA = engine.calculateHealth(
            targetFrequencyDays: a.targetFrequencyDays,
            lastInteractionDate: a.lastInteractionDate,
            priorityLevel: a.priorityLevel,
            averageGapDays: a.averageGapDays,
            createdAt: a.createdAt,
          );
          final statusB = engine.calculateHealth(
            targetFrequencyDays: b.targetFrequencyDays,
            lastInteractionDate: b.lastInteractionDate,
            priorityLevel: b.priorityLevel,
            averageGapDays: b.averageGapDays,
            createdAt: b.createdAt,
          );
          // Positive daysOverdue means more overdue. Sort descending.
          return statusB.daysOverdue.compareTo(statusA.daysOverdue);
        });
      case PersonSortOrder.lowestHealth:
        list.sort((a, b) {
          final statusA = engine.calculateHealth(
            targetFrequencyDays: a.targetFrequencyDays,
            lastInteractionDate: a.lastInteractionDate,
            priorityLevel: a.priorityLevel,
            averageGapDays: a.averageGapDays,
            createdAt: a.createdAt,
          );
          final statusB = engine.calculateHealth(
            targetFrequencyDays: b.targetFrequencyDays,
            lastInteractionDate: b.lastInteractionDate,
            priorityLevel: b.priorityLevel,
            averageGapDays: b.averageGapDays,
            createdAt: b.createdAt,
          );
          // Sort ascending (lowest score first)
          return statusA.baseScore.compareTo(statusB.baseScore);
        });
      case PersonSortOrder.highestPriority:
        // Sort descending (3 -> 1)
        list.sort((a, b) => b.priorityLevel.compareTo(a.priorityLevel));
      case PersonSortOrder.recentlyContacted:
        list.sort((a, b) {
          if (a.lastInteractionDate == null && b.lastInteractionDate == null) {
            return 0;
          }
          if (a.lastInteractionDate == null) {
            return 1;
          }
          if (b.lastInteractionDate == null) {
            return -1;
          }
          // Newest first
          return b.lastInteractionDate!.compareTo(a.lastInteractionDate!);
        });
      case PersonSortOrder.alphabetical:
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return list;
  }
}

@riverpod
Stream<List<Person>> sortedPeople(Ref ref) {
  final peopleAsync = ref.watch(allPeopleProvider);
  final order = ref.watch(sortOrderProvider);
  final engine = ref.watch(healthScoreEngineProvider);
  final sorter = ref.watch(sortingServiceProvider.notifier);

  return peopleAsync.when(
    data: (people) => Stream.value(sorter.sort(people, engine, order)),
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
}
