import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

import 'tables/people.dart';
import 'tables/labels.dart';
import 'tables/person_labels.dart';
import 'tables/interactions.dart';
import 'tables/person_connections.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [People, Labels, PersonLabels, Interactions, PersonConnections],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(people, people.relation);
        }
        if (from < 3) {
          await m.createTable(personConnections);
        }
        if (from < 4) {
          await m.addColumn(people, people.category as GeneratedColumn<Object>);
        }
        if (from < 5) {
          await m.addColumn(
            people,
            people.averageGapDays as GeneratedColumn<Object>,
          );
        }
      },
      beforeOpen: (details) async {
        // Essential for foreign keys to work
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'linksy.sqlite'));

    // SQLite configuration for Flutter apps

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
