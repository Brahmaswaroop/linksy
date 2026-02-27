import 'package:drift/drift.dart';
import 'people.dart';
import 'labels.dart';

@DataClassName('PersonLabel')
class PersonLabels extends Table {
  IntColumn get personId => integer().references(People, #id)();
  IntColumn get labelId => integer().references(Labels, #id)();

  @override
  Set<Column> get primaryKey => {personId, labelId};
}
