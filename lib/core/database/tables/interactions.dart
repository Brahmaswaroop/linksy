import 'package:drift/drift.dart';
import 'people.dart';

@DataClassName('Interaction')
class Interactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(People, #id)();

  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  /// e.g. "Meeting", "Call", "Message"
  TextColumn get type => text().withDefault(const Constant('Message'))();

  /// Range from 1 (Draining 🔴) to 5 (Energizing 🟢)
  IntColumn get energyRating => integer().nullable()();
}
