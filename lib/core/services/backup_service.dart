import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../database/database_provider.dart';

part 'backup_service.g.dart';

@riverpod
BackupService backupService(Ref ref) {
  return BackupService(ref.watch(databaseProvider));
}

class BackupService {
  final AppDatabase _db;
  
  BackupService(this._db);

  Future<String> exportData() async {
    final people = await _db.select(_db.people).get();
    final interactions = await _db.select(_db.interactions).get();
    final labels = await _db.select(_db.labels).get();
    final personLabels = await _db.select(_db.personLabels).get();
    final personConnections = await _db.select(_db.personConnections).get();

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'people': people.map((p) => p.toJson()).toList(),
      'interactions': interactions.map((i) => i.toJson()).toList(),
      'labels': labels.map((l) => l.toJson()).toList(),
      'person_labels': personLabels.map((pl) => pl.toJson()).toList(),
      'person_connections': personConnections.map((pc) => pc.toJson()).toList(),
    };

    final jsonStr = jsonEncode(data);
    
    // Save to temp directory for sharing/download
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/linksy_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonStr);
    
    return file.path;
  }

  Future<void> importData(String jsonStr) async {
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    
    // Basic validation
    if (!data.containsKey('people')) {
      throw const FormatException('Invalid backup file structure');
    }

    await _db.transaction(() async {
      // Clear existing data
      await _db.delete(_db.interactions).go();
      await _db.delete(_db.personLabels).go();
      await _db.delete(_db.personConnections).go();
      await _db.delete(_db.labels).go();
      await _db.delete(_db.people).go();

      // Insert people
      if (data['people'] != null) {
        final peopleList = (data['people'] as List)
            .map((e) => Person.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final p in peopleList) {
          await _db.into(_db.people).insert(p, mode: drift.InsertMode.insertOrReplace);
        }
      }

      // Insert labels
      if (data['labels'] != null) {
        final labelsList = (data['labels'] as List)
            .map((e) => Label.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final l in labelsList) {
          await _db.into(_db.labels).insert(l, mode: drift.InsertMode.insertOrReplace);
        }
      }

      // Insert interactions
      if (data['interactions'] != null) {
        final interactionsList = (data['interactions'] as List)
            .map((e) => Interaction.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final i in interactionsList) {
          await _db.into(_db.interactions).insert(i, mode: drift.InsertMode.insertOrReplace);
        }
      }

      // Insert person labels
      if (data['person_labels'] != null) {
        final personLabelsList = (data['person_labels'] as List)
            .map((e) => PersonLabel.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final pl in personLabelsList) {
          await _db.into(_db.personLabels).insert(pl, mode: drift.InsertMode.insertOrReplace);
        }
      }

      // Insert person connections
      if (data['person_connections'] != null) {
        final personConnectionsList = (data['person_connections'] as List)
            .map((e) => PersonConnection.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final pc in personConnectionsList) {
          await _db.into(_db.personConnections).insert(pc, mode: drift.InsertMode.insertOrReplace);
        }
      }
    });
  }
}
