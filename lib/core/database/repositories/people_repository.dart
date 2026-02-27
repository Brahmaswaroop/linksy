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

  Future<int> deletePerson(int id) {
    return (_db.delete(_db.people)..where((t) => t.id.equals(id))).go();
  }
}
