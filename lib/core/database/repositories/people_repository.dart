import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart';

part 'people_repository.g.dart';

@riverpod
PeopleRepository peopleRepository(Ref ref) {
  return PeopleRepository(ref.watch(databaseProvider));
}

@riverpod
Stream<List<Person>> allPeople(Ref ref) {
  return ref.watch(peopleRepositoryProvider).watchAllPeople();
}

@riverpod
Stream<Person> personStream(Ref ref, int personId) {
  return ref.watch(peopleRepositoryProvider).watchPerson(personId);
}

class PeopleRepository {
  final AppDatabase _db;
  PeopleRepository(this._db);

  Stream<List<Person>> watchAllPeople() {
    return (_db.select(_db.people)..orderBy([
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  Future<List<Person>> getAllPeople() {
    return (_db.select(_db.people)..orderBy([
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
        ]))
        .get();
  }

  Stream<Person> watchPerson(int id) {
    return (_db.select(
      _db.people,
    )..where((t) => t.id.equals(id))).watchSingle();
  }

  Future<Person> getPerson(int id) {
    return (_db.select(_db.people)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertPerson(PeopleCompanion person) {
    return _db.into(_db.people).insert(person);
  }

  Future<bool> updatePerson(Person person) {
    return _db.update(_db.people).replace(person);
  }

  Future<void> deletePerson(int id) async {
    await _db.transaction(() async {
      // Delete interactions
      await (_db.delete(_db.interactions)..where((t) => t.personId.equals(id))).go();
      // Delete person labels
      await (_db.delete(_db.personLabels)..where((t) => t.personId.equals(id))).go();
      // Delete person connections
      await (_db.delete(_db.personConnections)
            ..where((t) => t.personId.equals(id) | t.connectedPersonId.equals(id)))
          .go();
      // Delete the person
      await (_db.delete(_db.people)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> bulkUpdateCategory(List<int> personIds, String newCategory) async {
    await (_db.update(_db.people)..where((t) => t.id.isIn(personIds)))
        .write(PeopleCompanion(category: Value(newCategory)));
  }

  Future<void> bulkUpdatePriority(List<int> personIds, int newPriority) async {
    await (_db.update(_db.people)..where((t) => t.id.isIn(personIds)))
        .write(PeopleCompanion(priorityLevel: Value(newPriority)));
  }

  Future<void> bulkUpdateTargetFrequency(List<int> personIds, int newFrequency) async {
    await (_db.update(_db.people)..where((t) => t.id.isIn(personIds)))
        .write(PeopleCompanion(targetFrequencyDays: Value(newFrequency)));
  }

  Future<void> bulkDeletePeople(List<int> personIds) async {
    await _db.transaction(() async {
      for (final id in personIds) {
        // Delete interactions
        await (_db.delete(_db.interactions)..where((t) => t.personId.equals(id))).go();
        // Delete person labels
        await (_db.delete(_db.personLabels)..where((t) => t.personId.equals(id))).go();
        // Delete person connections
        await (_db.delete(_db.personConnections)
              ..where((t) => t.personId.equals(id) | t.connectedPersonId.equals(id)))
            .go();
        // Delete the person
        await (_db.delete(_db.people)..where((t) => t.id.equals(id))).go();
      }
    });
  }
}
