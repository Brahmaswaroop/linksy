import 'package:drift/drift.dart';
import 'people.dart';

@DataClassName('PersonConnection')
class PersonConnections extends Table {
  IntColumn get id => integer().autoIncrement()();

  // The first person in the relationship
  IntColumn get personId => integer().references(People, #id)();

  // The second person in the relationship
  IntColumn get connectedPersonId => integer().references(People, #id)();

  // E.g. "Friend", "Manager", "Spouse"
  TextColumn get relationLabel =>
      text().withDefault(const Constant('Connection'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
