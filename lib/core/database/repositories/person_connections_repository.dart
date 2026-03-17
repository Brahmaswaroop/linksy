import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';
import '../database_provider.dart';
import 'package:drift/drift.dart';
import '../../utils/relation_helper.dart';

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

@riverpod
Stream<List<PersonConnection>> allPersonConnections(Ref ref) {
  return ref.watch(personConnectionsRepositoryProvider).watchAllConnections();
}

class PersonConnectionsRepository {
  final AppDatabase _db;
  PersonConnectionsRepository(this._db);

  Stream<List<PersonConnection>> watchAllConnections() {
    return _db.select(_db.personConnections).watch();
  }

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
        .watch()
        .map((rows) {
          final Map<int, PersonConnection> unique = {};
          for (final row in rows) {
            final isDirect = row.personId == personId;
            final otherId = isDirect ? row.connectedPersonId : row.personId;

            if (isDirect) {
              // Explicit direct row. Keep as is.
              unique[otherId] = row;
            } else {
              // Legacy row or explicit reverse. Only use if direct is missing.
              if (!unique.containsKey(otherId)) {
                final inverseLabel = RelationHelper.getInverseRelation(
                  row.relationLabel,
                );
                final displayLabel = inverseLabel.isNotEmpty
                    ? inverseLabel[0].toUpperCase() + inverseLabel.substring(1)
                    : inverseLabel;
                unique[otherId] = row.copyWith(relationLabel: displayLabel);
              }
            }
          }
          return unique.values.toList();
        });
  }

  Future<int> insertConnection(PersonConnectionsCompanion connection) async {
    final p1 = connection.personId.value;
    final p2 = connection.connectedPersonId.value;

    // Check for existing connection in this exact direction
    final existing =
        await (_db.select(_db.personConnections)..where(
              (t) => t.personId.equals(p1) & t.connectedPersonId.equals(p2),
            ))
            .get();

    if (existing.isNotEmpty) {
      // Already connected, don't insert a duplicate. Return the existing ID.
      return existing.first.id;
    }

    return _db.into(_db.personConnections).insert(connection);
  }

  Future<void> updateConnectionPerspective(
    int sourcePersonId,
    int targetPersonId,
    String newLabel,
  ) async {
    // 1. Cleanly delete any existing logical connection forwards or backwards
    await (_db.delete(_db.personConnections)..where(
          (t) =>
              (t.personId.equals(sourcePersonId) &
                  t.connectedPersonId.equals(targetPersonId)) |
              (t.personId.equals(targetPersonId) &
                  t.connectedPersonId.equals(sourcePersonId)),
        ))
        .go();

    // 2. Insert the explicit direct row
    await _db
        .into(_db.personConnections)
        .insert(
          PersonConnectionsCompanion.insert(
            personId: sourcePersonId,
            connectedPersonId: targetPersonId,
            relationLabel: Value(newLabel),
          ),
        );

    // 3. Insert the explicit inverse row
    final inverseLabel = RelationHelper.getInverseRelation(newLabel);
    final displayInverse = inverseLabel.isNotEmpty
        ? inverseLabel[0].toUpperCase() + inverseLabel.substring(1)
        : inverseLabel;

    await _db
        .into(_db.personConnections)
        .insert(
          PersonConnectionsCompanion.insert(
            personId: targetPersonId,
            connectedPersonId: sourcePersonId,
            relationLabel: Value(displayInverse),
          ),
        );
  }

  Future<int> deleteConnection(int id) async {
    final conn = await (_db.select(
      _db.personConnections,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (conn != null) {
      await (_db.delete(_db.personConnections)..where(
            (t) =>
                t.personId.equals(conn.connectedPersonId) &
                t.connectedPersonId.equals(conn.personId),
          ))
          .go();
    }
    return (_db.delete(
      _db.personConnections,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<bool> updateConnection(PersonConnection connection) {
    return _db.update(_db.personConnections).replace(connection);
  }

  /// Optional: Get the other person ID given a connection and the current person ID
  int getOtherPersonId(PersonConnection connection, int currentPersonId) {
    return connection.personId == currentPersonId
        ? connection.connectedPersonId
        : connection.personId;
  }
}
