import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:linksy/core/database/database.dart';
import 'package:linksy/core/database/database_provider.dart';
import 'package:linksy/features/graph/graph_screen.dart';
import 'package:drift/drift.dart' hide Column;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('graphDataProvider clusters nodes correctly', () async {
    // Add 10 people in 'Friend' category
    for (int i = 1; i <= 10; i++) {
      await db.into(db.people).insert(
        PeopleCompanion.insert(
          name: 'Friend $i',
          category: const Value('Friend'),
          isWeak: const Value(false),
        ),
      );
    }

    // Add 2 people in 'Family' category
    for (int i = 1; i <= 2; i++) {
      await db.into(db.people).insert(
        PeopleCompanion.insert(
          name: 'Family $i',
          category: const Value('Family'),
          isWeak: const Value(false),
        ),
      );
    }

    // Add a weak connection: User -> Family 1 -> Weak 1
    final family1 = await (db.select(db.people)..where((t) => t.name.equals('Family 1'))).getSingle();
    await db.into(db.people).insert(
      PeopleCompanion.insert(
        name: 'Weak 1',
        category: const Value('Other'),
        isWeak: const Value(true),
      ),
    );
    final weak1 = await (db.select(db.people)..where((t) => t.name.equals('Weak 1'))).getSingle();
    
    await db.into(db.personConnections).insert(
      PersonConnectionsCompanion.insert(
        personId: family1.id,
        connectedPersonId: weak1.id,
        relationLabel: const Value('Introduced'),
        isWeak: const Value(true),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    final graphData = await container.read(graphDataProvider(0).future);

    // Filter out group nodes for uniqueness check by ID
    final individualNodeIds = graphData.nodes.where((n) => !n.isGroup).map((n) => n.id).toList();
    expect(individualNodeIds.length, individualNodeIds.toSet().length, reason: 'Duplicate individual node IDs found');

    // Expectations:
    // 1. You (ID 0) is present.
    // 2. 'Friend' cluster node is present (since count > 5).
    // 3. 'Family' nodes are present individually (since count <= 5).
    // 4. 'Weak 1' is present and linked to 'Family 1'.
    
    expect(graphData.nodes.any((n) => n.id == 0), true);
    expect(graphData.nodes.any((n) => n.isGroup && n.category == 'Friend' && n.memberCount == 10), true);
    expect(graphData.nodes.any((n) => !n.isGroup && n.name == 'Family 1'), true);
    expect(graphData.nodes.any((n) => n.name == 'Weak 1' && n.isWeak), true);

    final weakEdge = graphData.edges.firstWhere((e) => e.targetId == weak1.id);
    expect(weakEdge.sourceId, family1.id);
  });
}
