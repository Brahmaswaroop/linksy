import 'package:drift/drift.dart';

@DataClassName('Person')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// 1 = Low, 2 = Medium, 3 = High
  IntColumn get priorityLevel => integer().withDefault(const Constant(2))();

  /// Target interaction frequency in days
  IntColumn get targetFrequencyDays =>
      integer().withDefault(const Constant(30))();

  DateTimeColumn get lastInteractionDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get avatarPath => text().nullable()();
  TextColumn get relation => text().nullable()();

  /// Current true computed average gap between interactions (in days)
  RealColumn get averageGapDays => real().nullable()();

  /// E.g. 'Friend', 'Family', 'Colleague', 'Other'
  TextColumn get category => text().withDefault(const Constant('Other'))();
}
