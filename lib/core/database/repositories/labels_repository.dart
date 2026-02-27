import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart';

part 'labels_repository.g.dart';

@riverpod
LabelsRepository labelsRepository(Ref ref) {
  return LabelsRepository(ref.watch(databaseProvider));
}

@riverpod
Stream<List<Label>> allLabels(Ref ref) {
  return ref.watch(labelsRepositoryProvider).watchAllLabels();
}

@riverpod
Stream<List<Label>> labelsForPerson(Ref ref, int personId) {
  return ref.watch(labelsRepositoryProvider).watchLabelsForPerson(personId);
}

class LabelsRepository {
  final AppDatabase _db;
  LabelsRepository(this._db);

  Stream<List<Label>> watchAllLabels() {
    return (_db.select(_db.labels)..orderBy([
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  Future<Label> getLabel(int id) {
    return (_db.select(_db.labels)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertLabel(LabelsCompanion label) {
    return _db.into(_db.labels).insert(label);
  }

  Future<bool> updateLabel(Label label) {
    return _db.update(_db.labels).replace(label);
  }

  Future<int> deleteLabel(int id) {
    return (_db.delete(_db.labels)..where((t) => t.id.equals(id))).go();
  }

  // Many-to-Many Operations for PersonLabels
  Future<void> attachLabelToPerson(int personId, int labelId) async {
    await _db
        .into(_db.personLabels)
        .insert(
          PersonLabelsCompanion(
            personId: Value(personId),
            labelId: Value(labelId),
          ),
          mode: InsertMode.insertOrIgnore, // Avoid duplicates seamlessly
        );
  }

  Future<void> detachLabelFromPerson(int personId, int labelId) async {
    await (_db.delete(_db.personLabels)..where(
          (t) => t.personId.equals(personId) & t.labelId.equals(labelId),
        ))
        .go();
  }

  // Use a join to get labels for a specific person
  Stream<List<Label>> watchLabelsForPerson(int personId) {
    final query = _db.select(_db.labels).join([
      innerJoin(
        _db.personLabels,
        _db.personLabels.labelId.equalsExp(_db.labels.id),
      ),
    ])..where(_db.personLabels.personId.equals(personId));

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(_db.labels)).toList();
    });
  }

  Future<List<Label>> getLabelsForPerson(int personId) async {
    final query = _db.select(_db.labels).join([
      innerJoin(
        _db.personLabels,
        _db.personLabels.labelId.equalsExp(_db.labels.id),
      ),
    ])..where(_db.personLabels.personId.equals(personId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.labels)).toList();
  }

  Future<void> clearLabelsForPerson(int personId) async {
    await (_db.delete(
      _db.personLabels,
    )..where((t) => t.personId.equals(personId))).go();
  }
}
