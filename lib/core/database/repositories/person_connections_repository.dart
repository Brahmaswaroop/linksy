import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart';

part 'person_connections_repository.g.dart';

@riverpod
PersonConnectionsRepository personConnectionsRepository(Ref ref) {
  return PersonConnectionsRepository(ref.watch(databaseProvider));
}

@riverpod
Stream<List<PersonConnection>> personConnections(Ref ref, int personId) {
  return ref
      .watch(personConnectionsRepositoryProvider)
      .watchConnectionsForPerson(personId);
}

class PersonConnectionsRepository {
  final AppDatabase _db;
  PersonConnectionsRepository(this._db);

  Stream<List<PersonConnection>> watchConnectionsForPerson(int personId) {
    return (_db.select(_db.personConnections)
          ..where(
            (t) =>
                t.personId.equals(personId) |
                t.connectedPersonId.equals(personId),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> insertConnection(PersonConnectionsCompanion connection) async {
    final p1 = connection.personId.value;
    final p2 = connection.connectedPersonId.value;

    // Check for existing connection in either direction
    final existing =
        await (_db.select(_db.personConnections)..where(
              (t) =>
                  (t.personId.equals(p1) & t.connectedPersonId.equals(p2)) |
                  (t.personId.equals(p2) & t.connectedPersonId.equals(p1)),
            ))
            .get();

    if (existing.isNotEmpty) {
      // Already connected, don't insert a duplicate. Return the existing ID.
      return existing.first.id;
    }

    return _db.into(_db.personConnections).insert(connection);
  }

  Future<int> deleteConnection(int id) {
    return (_db.delete(
      _db.personConnections,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Optional: Get the other person ID given a connection and the current person ID
  int getOtherPersonId(PersonConnection connection, int currentPersonId) {
    return connection.personId == currentPersonId
        ? connection.connectedPersonId
        : connection.personId;
  }
}
