import 'package:drift/drift.dart';

@DataClassName('Label')
class Labels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();
  TextColumn get colorHex => text()
      .withLength(max: 9)
      .withDefault(const Constant('#FF8E8E8E'))(); // default grey
}
