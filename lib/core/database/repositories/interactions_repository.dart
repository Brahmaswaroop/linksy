import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart';

part 'interactions_repository.g.dart';

@riverpod
InteractionsRepository interactionsRepository(Ref ref) {
  return InteractionsRepository(ref.watch(databaseProvider));
}

@riverpod
Stream<List<Interaction>> personInteractions(Ref ref, int personId) {
  return ref
      .watch(interactionsRepositoryProvider)
      .watchInteractionsForPerson(personId);
}

class InteractionsRepository {
  final AppDatabase _db;
  InteractionsRepository(this._db);

  Stream<List<Interaction>> watchInteractionsForPerson(int personId) {
    return (_db.select(_db.interactions)
          ..where((t) => t.personId.equals(personId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> logInteraction(InteractionsCompanion interaction) async {
    return await _db.transaction(() async {
      // Insert interaction
      final newId = await _db.into(_db.interactions).insert(interaction);

      await _updatePersonAverageGapAndDate(interaction.personId.value);

      return newId;
    });
  }

  Future<int> deleteInteraction(int id) async {
    return await _db.transaction(() async {
      // Fetch interaction to know which person it belongs to
      final interaction = await (_db.select(
        _db.interactions,
      )..where((t) => t.id.equals(id))).getSingle();

      final result = await (_db.delete(
        _db.interactions,
      )..where((t) => t.id.equals(id))).go();

      await _updatePersonAverageGapAndDate(interaction.personId);

      return result;
    });
  }

  Future<void> _updatePersonAverageGapAndDate(int personId) async {
    // Fetch all interactions for this person, ascending by date
    final interactions =
        await (_db.select(_db.interactions)
              ..where((t) => t.personId.equals(personId))
              ..orderBy([
                (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
              ]))
            .get();

    DateTime? lastInteractionDate;
    double? averageGapDays;

    if (interactions.isNotEmpty) {
      lastInteractionDate = interactions.last.date;

      if (interactions.length >= 2) {
        int totalGapDays = 0;
        for (int i = 1; i < interactions.length; i++) {
          totalGapDays += interactions[i].date
              .difference(interactions[i - 1].date)
              .inDays;
        }
        averageGapDays = totalGapDays / (interactions.length - 1);
      }
    }

    // Update Person
    final person = await (_db.select(
      _db.people,
    )..where((t) => t.id.equals(personId))).getSingle();

    await _db
        .update(_db.people)
        .replace(
          person.copyWith(
            lastInteractionDate: interactions.isEmpty
                ? const Value.absent()
                : Value(lastInteractionDate),
            averageGapDays: averageGapDays == null
                ? const Value.absent() // clear it if they drop under 2
                : Value(averageGapDays),
          ),
        );
  }
}
