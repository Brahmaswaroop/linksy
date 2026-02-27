// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PeopleTable extends People with TableInfo<$PeopleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityLevelMeta = const VerificationMeta(
    'priorityLevel',
  );
  @override
  late final GeneratedColumn<int> priorityLevel = GeneratedColumn<int>(
    'priority_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _targetFrequencyDaysMeta =
      const VerificationMeta('targetFrequencyDays');
  @override
  late final GeneratedColumn<int> targetFrequencyDays = GeneratedColumn<int>(
    'target_frequency_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _lastInteractionDateMeta =
      const VerificationMeta('lastInteractionDate');
  @override
  late final GeneratedColumn<DateTime> lastInteractionDate =
      GeneratedColumn<DateTime>(
        'last_interaction_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageGapDaysMeta = const VerificationMeta(
    'averageGapDays',
  );
  @override
  late final GeneratedColumn<double> averageGapDays = GeneratedColumn<double>(
    'average_gap_days',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    priorityLevel,
    targetFrequencyDays,
    lastInteractionDate,
    createdAt,
    avatarPath,
    relation,
    averageGapDays,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<Person> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('priority_level')) {
      context.handle(
        _priorityLevelMeta,
        priorityLevel.isAcceptableOrUnknown(
          data['priority_level']!,
          _priorityLevelMeta,
        ),
      );
    }
    if (data.containsKey('target_frequency_days')) {
      context.handle(
        _targetFrequencyDaysMeta,
        targetFrequencyDays.isAcceptableOrUnknown(
          data['target_frequency_days']!,
          _targetFrequencyDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_interaction_date')) {
      context.handle(
        _lastInteractionDateMeta,
        lastInteractionDate.isAcceptableOrUnknown(
          data['last_interaction_date']!,
          _lastInteractionDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('average_gap_days')) {
      context.handle(
        _averageGapDaysMeta,
        averageGapDays.isAcceptableOrUnknown(
          data['average_gap_days']!,
          _averageGapDaysMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priorityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority_level'],
      )!,
      targetFrequencyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_frequency_days'],
      )!,
      lastInteractionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interaction_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      ),
      averageGapDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_gap_days'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final int id;
  final String name;

  /// 1 = Low, 2 = Medium, 3 = High
  final int priorityLevel;

  /// Target interaction frequency in days
  final int targetFrequencyDays;
  final DateTime? lastInteractionDate;
  final DateTime createdAt;
  final String? avatarPath;
  final String? relation;

  /// Current true computed average gap between interactions (in days)
  final double? averageGapDays;

  /// E.g. 'Friend', 'Family', 'Colleague', 'Other'
  final String category;
  const Person({
    required this.id,
    required this.name,
    required this.priorityLevel,
    required this.targetFrequencyDays,
    this.lastInteractionDate,
    required this.createdAt,
    this.avatarPath,
    this.relation,
    this.averageGapDays,
    required this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['priority_level'] = Variable<int>(priorityLevel);
    map['target_frequency_days'] = Variable<int>(targetFrequencyDays);
    if (!nullToAbsent || lastInteractionDate != null) {
      map['last_interaction_date'] = Variable<DateTime>(lastInteractionDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || relation != null) {
      map['relation'] = Variable<String>(relation);
    }
    if (!nullToAbsent || averageGapDays != null) {
      map['average_gap_days'] = Variable<double>(averageGapDays);
    }
    map['category'] = Variable<String>(category);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      priorityLevel: Value(priorityLevel),
      targetFrequencyDays: Value(targetFrequencyDays),
      lastInteractionDate: lastInteractionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractionDate),
      createdAt: Value(createdAt),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      relation: relation == null && nullToAbsent
          ? const Value.absent()
          : Value(relation),
      averageGapDays: averageGapDays == null && nullToAbsent
          ? const Value.absent()
          : Value(averageGapDays),
      category: Value(category),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      priorityLevel: serializer.fromJson<int>(json['priorityLevel']),
      targetFrequencyDays: serializer.fromJson<int>(
        json['targetFrequencyDays'],
      ),
      lastInteractionDate: serializer.fromJson<DateTime?>(
        json['lastInteractionDate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      relation: serializer.fromJson<String?>(json['relation']),
      averageGapDays: serializer.fromJson<double?>(json['averageGapDays']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'priorityLevel': serializer.toJson<int>(priorityLevel),
      'targetFrequencyDays': serializer.toJson<int>(targetFrequencyDays),
      'lastInteractionDate': serializer.toJson<DateTime?>(lastInteractionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'relation': serializer.toJson<String?>(relation),
      'averageGapDays': serializer.toJson<double?>(averageGapDays),
      'category': serializer.toJson<String>(category),
    };
  }

  Person copyWith({
    int? id,
    String? name,
    int? priorityLevel,
    int? targetFrequencyDays,
    Value<DateTime?> lastInteractionDate = const Value.absent(),
    DateTime? createdAt,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> relation = const Value.absent(),
    Value<double?> averageGapDays = const Value.absent(),
    String? category,
  }) => Person(
    id: id ?? this.id,
    name: name ?? this.name,
    priorityLevel: priorityLevel ?? this.priorityLevel,
    targetFrequencyDays: targetFrequencyDays ?? this.targetFrequencyDays,
    lastInteractionDate: lastInteractionDate.present
        ? lastInteractionDate.value
        : this.lastInteractionDate,
    createdAt: createdAt ?? this.createdAt,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    relation: relation.present ? relation.value : this.relation,
    averageGapDays: averageGapDays.present
        ? averageGapDays.value
        : this.averageGapDays,
    category: category ?? this.category,
  );
  Person copyWithCompanion(PeopleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      priorityLevel: data.priorityLevel.present
          ? data.priorityLevel.value
          : this.priorityLevel,
      targetFrequencyDays: data.targetFrequencyDays.present
          ? data.targetFrequencyDays.value
          : this.targetFrequencyDays,
      lastInteractionDate: data.lastInteractionDate.present
          ? data.lastInteractionDate.value
          : this.lastInteractionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      relation: data.relation.present ? data.relation.value : this.relation,
      averageGapDays: data.averageGapDays.present
          ? data.averageGapDays.value
          : this.averageGapDays,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('targetFrequencyDays: $targetFrequencyDays, ')
          ..write('lastInteractionDate: $lastInteractionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('relation: $relation, ')
          ..write('averageGapDays: $averageGapDays, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    priorityLevel,
    targetFrequencyDays,
    lastInteractionDate,
    createdAt,
    avatarPath,
    relation,
    averageGapDays,
    category,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.name == this.name &&
          other.priorityLevel == this.priorityLevel &&
          other.targetFrequencyDays == this.targetFrequencyDays &&
          other.lastInteractionDate == this.lastInteractionDate &&
          other.createdAt == this.createdAt &&
          other.avatarPath == this.avatarPath &&
          other.relation == this.relation &&
          other.averageGapDays == this.averageGapDays &&
          other.category == this.category);
}

class PeopleCompanion extends UpdateCompanion<Person> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> priorityLevel;
  final Value<int> targetFrequencyDays;
  final Value<DateTime?> lastInteractionDate;
  final Value<DateTime> createdAt;
  final Value<String?> avatarPath;
  final Value<String?> relation;
  final Value<double?> averageGapDays;
  final Value<String> category;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.targetFrequencyDays = const Value.absent(),
    this.lastInteractionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.relation = const Value.absent(),
    this.averageGapDays = const Value.absent(),
    this.category = const Value.absent(),
  });
  PeopleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.priorityLevel = const Value.absent(),
    this.targetFrequencyDays = const Value.absent(),
    this.lastInteractionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.relation = const Value.absent(),
    this.averageGapDays = const Value.absent(),
    this.category = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Person> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? priorityLevel,
    Expression<int>? targetFrequencyDays,
    Expression<DateTime>? lastInteractionDate,
    Expression<DateTime>? createdAt,
    Expression<String>? avatarPath,
    Expression<String>? relation,
    Expression<double>? averageGapDays,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (priorityLevel != null) 'priority_level': priorityLevel,
      if (targetFrequencyDays != null)
        'target_frequency_days': targetFrequencyDays,
      if (lastInteractionDate != null)
        'last_interaction_date': lastInteractionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (relation != null) 'relation': relation,
      if (averageGapDays != null) 'average_gap_days': averageGapDays,
      if (category != null) 'category': category,
    });
  }

  PeopleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? priorityLevel,
    Value<int>? targetFrequencyDays,
    Value<DateTime?>? lastInteractionDate,
    Value<DateTime>? createdAt,
    Value<String?>? avatarPath,
    Value<String?>? relation,
    Value<double?>? averageGapDays,
    Value<String>? category,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      targetFrequencyDays: targetFrequencyDays ?? this.targetFrequencyDays,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      createdAt: createdAt ?? this.createdAt,
      avatarPath: avatarPath ?? this.avatarPath,
      relation: relation ?? this.relation,
      averageGapDays: averageGapDays ?? this.averageGapDays,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priorityLevel.present) {
      map['priority_level'] = Variable<int>(priorityLevel.value);
    }
    if (targetFrequencyDays.present) {
      map['target_frequency_days'] = Variable<int>(targetFrequencyDays.value);
    }
    if (lastInteractionDate.present) {
      map['last_interaction_date'] = Variable<DateTime>(
        lastInteractionDate.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (averageGapDays.present) {
      map['average_gap_days'] = Variable<double>(averageGapDays.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('targetFrequencyDays: $targetFrequencyDays, ')
          ..write('lastInteractionDate: $lastInteractionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('relation: $relation, ')
          ..write('averageGapDays: $averageGapDays, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels with TableInfo<$LabelsTable, Label> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 9),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FF8E8E8E'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colorHex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Label> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Label map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Label(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class Label extends DataClass implements Insertable<Label> {
  final int id;
  final String name;
  final String colorHex;
  const Label({required this.id, required this.name, required this.colorHex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
    );
  }

  factory Label.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Label(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
    };
  }

  Label copyWith({int? id, String? name, String? colorHex}) => Label(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
  );
  Label copyWithCompanion(LabelsCompanion data) {
    return Label(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Label(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex);
}

class LabelsCompanion extends UpdateCompanion<Label> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorHex;
  const LabelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
  });
  LabelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorHex = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Label> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
    });
  }

  LabelsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? colorHex,
  }) {
    return LabelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }
}

class $PersonLabelsTable extends PersonLabels
    with TableInfo<$PersonLabelsTable, PersonLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES labels (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [personId, labelId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonLabel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {personId, labelId};
  @override
  PersonLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonLabel(
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label_id'],
      )!,
    );
  }

  @override
  $PersonLabelsTable createAlias(String alias) {
    return $PersonLabelsTable(attachedDatabase, alias);
  }
}

class PersonLabel extends DataClass implements Insertable<PersonLabel> {
  final int personId;
  final int labelId;
  const PersonLabel({required this.personId, required this.labelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['person_id'] = Variable<int>(personId);
    map['label_id'] = Variable<int>(labelId);
    return map;
  }

  PersonLabelsCompanion toCompanion(bool nullToAbsent) {
    return PersonLabelsCompanion(
      personId: Value(personId),
      labelId: Value(labelId),
    );
  }

  factory PersonLabel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonLabel(
      personId: serializer.fromJson<int>(json['personId']),
      labelId: serializer.fromJson<int>(json['labelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'personId': serializer.toJson<int>(personId),
      'labelId': serializer.toJson<int>(labelId),
    };
  }

  PersonLabel copyWith({int? personId, int? labelId}) => PersonLabel(
    personId: personId ?? this.personId,
    labelId: labelId ?? this.labelId,
  );
  PersonLabel copyWithCompanion(PersonLabelsCompanion data) {
    return PersonLabel(
      personId: data.personId.present ? data.personId.value : this.personId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonLabel(')
          ..write('personId: $personId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(personId, labelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonLabel &&
          other.personId == this.personId &&
          other.labelId == this.labelId);
}

class PersonLabelsCompanion extends UpdateCompanion<PersonLabel> {
  final Value<int> personId;
  final Value<int> labelId;
  final Value<int> rowid;
  const PersonLabelsCompanion({
    this.personId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonLabelsCompanion.insert({
    required int personId,
    required int labelId,
    this.rowid = const Value.absent(),
  }) : personId = Value(personId),
       labelId = Value(labelId);
  static Insertable<PersonLabel> custom({
    Expression<int>? personId,
    Expression<int>? labelId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (personId != null) 'person_id': personId,
      if (labelId != null) 'label_id': labelId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonLabelsCompanion copyWith({
    Value<int>? personId,
    Value<int>? labelId,
    Value<int>? rowid,
  }) {
    return PersonLabelsCompanion(
      personId: personId ?? this.personId,
      labelId: labelId ?? this.labelId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonLabelsCompanion(')
          ..write('personId: $personId, ')
          ..write('labelId: $labelId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionsTable extends Interactions
    with TableInfo<$InteractionsTable, Interaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Message'),
  );
  static const VerificationMeta _energyRatingMeta = const VerificationMeta(
    'energyRating',
  );
  @override
  late final GeneratedColumn<int> energyRating = GeneratedColumn<int>(
    'energy_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    date,
    notes,
    type,
    energyRating,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Interaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('energy_rating')) {
      context.handle(
        _energyRatingMeta,
        energyRating.isAcceptableOrUnknown(
          data['energy_rating']!,
          _energyRatingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Interaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Interaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      energyRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_rating'],
      ),
    );
  }

  @override
  $InteractionsTable createAlias(String alias) {
    return $InteractionsTable(attachedDatabase, alias);
  }
}

class Interaction extends DataClass implements Insertable<Interaction> {
  final int id;
  final int personId;
  final DateTime date;
  final String? notes;

  /// e.g. "Meeting", "Call", "Message"
  final String type;

  /// Range from 1 (Draining 🔴) to 5 (Energizing 🟢)
  final int? energyRating;
  const Interaction({
    required this.id,
    required this.personId,
    required this.date,
    this.notes,
    required this.type,
    this.energyRating,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || energyRating != null) {
      map['energy_rating'] = Variable<int>(energyRating);
    }
    return map;
  }

  InteractionsCompanion toCompanion(bool nullToAbsent) {
    return InteractionsCompanion(
      id: Value(id),
      personId: Value(personId),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      type: Value(type),
      energyRating: energyRating == null && nullToAbsent
          ? const Value.absent()
          : Value(energyRating),
    );
  }

  factory Interaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Interaction(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      type: serializer.fromJson<String>(json['type']),
      energyRating: serializer.fromJson<int?>(json['energyRating']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'type': serializer.toJson<String>(type),
      'energyRating': serializer.toJson<int?>(energyRating),
    };
  }

  Interaction copyWith({
    int? id,
    int? personId,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    String? type,
    Value<int?> energyRating = const Value.absent(),
  }) => Interaction(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    type: type ?? this.type,
    energyRating: energyRating.present ? energyRating.value : this.energyRating,
  );
  Interaction copyWithCompanion(InteractionsCompanion data) {
    return Interaction(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      type: data.type.present ? data.type.value : this.type,
      energyRating: data.energyRating.present
          ? data.energyRating.value
          : this.energyRating,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Interaction(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('energyRating: $energyRating')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personId, date, notes, type, energyRating);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Interaction &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.type == this.type &&
          other.energyRating == this.energyRating);
}

class InteractionsCompanion extends UpdateCompanion<Interaction> {
  final Value<int> id;
  final Value<int> personId;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String> type;
  final Value<int?> energyRating;
  const InteractionsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.energyRating = const Value.absent(),
  });
  InteractionsCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.energyRating = const Value.absent(),
  }) : personId = Value(personId);
  static Insertable<Interaction> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? type,
    Expression<int>? energyRating,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (type != null) 'type': type,
      if (energyRating != null) 'energy_rating': energyRating,
    });
  }

  InteractionsCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String>? type,
    Value<int?>? energyRating,
  }) {
    return InteractionsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      energyRating: energyRating ?? this.energyRating,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (energyRating.present) {
      map['energy_rating'] = Variable<int>(energyRating.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('energyRating: $energyRating')
          ..write(')'))
        .toString();
  }
}

class $PersonConnectionsTable extends PersonConnections
    with TableInfo<$PersonConnectionsTable, PersonConnection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _connectedPersonIdMeta = const VerificationMeta(
    'connectedPersonId',
  );
  @override
  late final GeneratedColumn<int> connectedPersonId = GeneratedColumn<int>(
    'connected_person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _relationLabelMeta = const VerificationMeta(
    'relationLabel',
  );
  @override
  late final GeneratedColumn<String> relationLabel = GeneratedColumn<String>(
    'relation_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Connection'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    connectedPersonId,
    relationLabel,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonConnection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('connected_person_id')) {
      context.handle(
        _connectedPersonIdMeta,
        connectedPersonId.isAcceptableOrUnknown(
          data['connected_person_id']!,
          _connectedPersonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedPersonIdMeta);
    }
    if (data.containsKey('relation_label')) {
      context.handle(
        _relationLabelMeta,
        relationLabel.isAcceptableOrUnknown(
          data['relation_label']!,
          _relationLabelMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonConnection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonConnection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      connectedPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}connected_person_id'],
      )!,
      relationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonConnectionsTable createAlias(String alias) {
    return $PersonConnectionsTable(attachedDatabase, alias);
  }
}

class PersonConnection extends DataClass
    implements Insertable<PersonConnection> {
  final int id;
  final int personId;
  final int connectedPersonId;
  final String relationLabel;
  final DateTime createdAt;
  const PersonConnection({
    required this.id,
    required this.personId,
    required this.connectedPersonId,
    required this.relationLabel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['connected_person_id'] = Variable<int>(connectedPersonId);
    map['relation_label'] = Variable<String>(relationLabel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonConnectionsCompanion toCompanion(bool nullToAbsent) {
    return PersonConnectionsCompanion(
      id: Value(id),
      personId: Value(personId),
      connectedPersonId: Value(connectedPersonId),
      relationLabel: Value(relationLabel),
      createdAt: Value(createdAt),
    );
  }

  factory PersonConnection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonConnection(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      connectedPersonId: serializer.fromJson<int>(json['connectedPersonId']),
      relationLabel: serializer.fromJson<String>(json['relationLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'connectedPersonId': serializer.toJson<int>(connectedPersonId),
      'relationLabel': serializer.toJson<String>(relationLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonConnection copyWith({
    int? id,
    int? personId,
    int? connectedPersonId,
    String? relationLabel,
    DateTime? createdAt,
  }) => PersonConnection(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    connectedPersonId: connectedPersonId ?? this.connectedPersonId,
    relationLabel: relationLabel ?? this.relationLabel,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonConnection copyWithCompanion(PersonConnectionsCompanion data) {
    return PersonConnection(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      connectedPersonId: data.connectedPersonId.present
          ? data.connectedPersonId.value
          : this.connectedPersonId,
      relationLabel: data.relationLabel.present
          ? data.relationLabel.value
          : this.relationLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonConnection(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('connectedPersonId: $connectedPersonId, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, personId, connectedPersonId, relationLabel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonConnection &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.connectedPersonId == this.connectedPersonId &&
          other.relationLabel == this.relationLabel &&
          other.createdAt == this.createdAt);
}

class PersonConnectionsCompanion extends UpdateCompanion<PersonConnection> {
  final Value<int> id;
  final Value<int> personId;
  final Value<int> connectedPersonId;
  final Value<String> relationLabel;
  final Value<DateTime> createdAt;
  const PersonConnectionsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.connectedPersonId = const Value.absent(),
    this.relationLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    required int connectedPersonId,
    this.relationLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : personId = Value(personId),
       connectedPersonId = Value(connectedPersonId);
  static Insertable<PersonConnection> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<int>? connectedPersonId,
    Expression<String>? relationLabel,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (connectedPersonId != null) 'connected_person_id': connectedPersonId,
      if (relationLabel != null) 'relation_label': relationLabel,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonConnectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<int>? connectedPersonId,
    Value<String>? relationLabel,
    Value<DateTime>? createdAt,
  }) {
    return PersonConnectionsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      connectedPersonId: connectedPersonId ?? this.connectedPersonId,
      relationLabel: relationLabel ?? this.relationLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (connectedPersonId.present) {
      map['connected_person_id'] = Variable<int>(connectedPersonId.value);
    }
    if (relationLabel.present) {
      map['relation_label'] = Variable<String>(relationLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('connectedPersonId: $connectedPersonId, ')
          ..write('relationLabel: $relationLabel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $PersonLabelsTable personLabels = $PersonLabelsTable(this);
  late final $InteractionsTable interactions = $InteractionsTable(this);
  late final $PersonConnectionsTable personConnections =
      $PersonConnectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    people,
    labels,
    personLabels,
    interactions,
    personConnections,
  ];
}

typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      Value<int> id,
      required String name,
      Value<int> priorityLevel,
      Value<int> targetFrequencyDays,
      Value<DateTime?> lastInteractionDate,
      Value<DateTime> createdAt,
      Value<String?> avatarPath,
      Value<String?> relation,
      Value<double?> averageGapDays,
      Value<String> category,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> priorityLevel,
      Value<int> targetFrequencyDays,
      Value<DateTime?> lastInteractionDate,
      Value<DateTime> createdAt,
      Value<String?> avatarPath,
      Value<String?> relation,
      Value<double?> averageGapDays,
      Value<String> category,
    });

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, Person> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonLabelsTable, List<PersonLabel>>
  _personLabelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personLabels,
    aliasName: $_aliasNameGenerator(db.people.id, db.personLabels.personId),
  );

  $$PersonLabelsTableProcessedTableManager get personLabelsRefs {
    final manager = $$PersonLabelsTableTableManager(
      $_db,
      $_db.personLabels,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_personLabelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InteractionsTable, List<Interaction>>
  _interactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.interactions,
    aliasName: $_aliasNameGenerator(db.people.id, db.interactions.personId),
  );

  $$InteractionsTableProcessedTableManager get interactionsRefs {
    final manager = $$InteractionsTableTableManager(
      $_db,
      $_db.interactions,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_interactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorityLevel => $composableBuilder(
    column: $table.priorityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFrequencyDays => $composableBuilder(
    column: $table.targetFrequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteractionDate => $composableBuilder(
    column: $table.lastInteractionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageGapDays => $composableBuilder(
    column: $table.averageGapDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personLabelsRefs(
    Expression<bool> Function($$PersonLabelsTableFilterComposer f) f,
  ) {
    final $$PersonLabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personLabels,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonLabelsTableFilterComposer(
            $db: $db,
            $table: $db.personLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> interactionsRefs(
    Expression<bool> Function($$InteractionsTableFilterComposer f) f,
  ) {
    final $$InteractionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interactions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InteractionsTableFilterComposer(
            $db: $db,
            $table: $db.interactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorityLevel => $composableBuilder(
    column: $table.priorityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFrequencyDays => $composableBuilder(
    column: $table.targetFrequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteractionDate => $composableBuilder(
    column: $table.lastInteractionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageGapDays => $composableBuilder(
    column: $table.averageGapDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priorityLevel => $composableBuilder(
    column: $table.priorityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetFrequencyDays => $composableBuilder(
    column: $table.targetFrequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastInteractionDate => $composableBuilder(
    column: $table.lastInteractionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<double> get averageGapDays => $composableBuilder(
    column: $table.averageGapDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  Expression<T> personLabelsRefs<T extends Object>(
    Expression<T> Function($$PersonLabelsTableAnnotationComposer a) f,
  ) {
    final $$PersonLabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personLabels,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonLabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.personLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> interactionsRefs<T extends Object>(
    Expression<T> Function($$InteractionsTableAnnotationComposer a) f,
  ) {
    final $$InteractionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interactions,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InteractionsTableAnnotationComposer(
            $db: $db,
            $table: $db.interactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          Person,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (Person, $$PeopleTableReferences),
          Person,
          PrefetchHooks Function({bool personLabelsRefs, bool interactionsRefs})
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priorityLevel = const Value.absent(),
                Value<int> targetFrequencyDays = const Value.absent(),
                Value<DateTime?> lastInteractionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<double?> averageGapDays = const Value.absent(),
                Value<String> category = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                name: name,
                priorityLevel: priorityLevel,
                targetFrequencyDays: targetFrequencyDays,
                lastInteractionDate: lastInteractionDate,
                createdAt: createdAt,
                avatarPath: avatarPath,
                relation: relation,
                averageGapDays: averageGapDays,
                category: category,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> priorityLevel = const Value.absent(),
                Value<int> targetFrequencyDays = const Value.absent(),
                Value<DateTime?> lastInteractionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<double?> averageGapDays = const Value.absent(),
                Value<String> category = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                name: name,
                priorityLevel: priorityLevel,
                targetFrequencyDays: targetFrequencyDays,
                lastInteractionDate: lastInteractionDate,
                createdAt: createdAt,
                avatarPath: avatarPath,
                relation: relation,
                averageGapDays: averageGapDays,
                category: category,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PeopleTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({personLabelsRefs = false, interactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personLabelsRefs) db.personLabels,
                    if (interactionsRefs) db.interactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personLabelsRefs)
                        await $_getPrefetchedData<
                          Person,
                          $PeopleTable,
                          PersonLabel
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._personLabelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).personLabelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (interactionsRefs)
                        await $_getPrefetchedData<
                          Person,
                          $PeopleTable,
                          Interaction
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._interactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).interactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      Person,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (Person, $$PeopleTableReferences),
      Person,
      PrefetchHooks Function({bool personLabelsRefs, bool interactionsRefs})
    >;
typedef $$LabelsTableCreateCompanionBuilder =
    LabelsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> colorHex,
    });
typedef $$LabelsTableUpdateCompanionBuilder =
    LabelsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> colorHex,
    });

final class $$LabelsTableReferences
    extends BaseReferences<_$AppDatabase, $LabelsTable, Label> {
  $$LabelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonLabelsTable, List<PersonLabel>>
  _personLabelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personLabels,
    aliasName: $_aliasNameGenerator(db.labels.id, db.personLabels.labelId),
  );

  $$PersonLabelsTableProcessedTableManager get personLabelsRefs {
    final manager = $$PersonLabelsTableTableManager(
      $_db,
      $_db.personLabels,
    ).filter((f) => f.labelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_personLabelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LabelsTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personLabelsRefs(
    Expression<bool> Function($$PersonLabelsTableFilterComposer f) f,
  ) {
    final $$PersonLabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personLabels,
      getReferencedColumn: (t) => t.labelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonLabelsTableFilterComposer(
            $db: $db,
            $table: $db.personLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  Expression<T> personLabelsRefs<T extends Object>(
    Expression<T> Function($$PersonLabelsTableAnnotationComposer a) f,
  ) {
    final $$PersonLabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personLabels,
      getReferencedColumn: (t) => t.labelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonLabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.personLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTable,
          Label,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (Label, $$LabelsTableReferences),
          Label,
          PrefetchHooks Function({bool personLabelsRefs})
        > {
  $$LabelsTableTableManager(_$AppDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
              }) => LabelsCompanion(id: id, name: name, colorHex: colorHex),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> colorHex = const Value.absent(),
              }) => LabelsCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LabelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({personLabelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (personLabelsRefs) db.personLabels],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (personLabelsRefs)
                    await $_getPrefetchedData<Label, $LabelsTable, PersonLabel>(
                      currentTable: table,
                      referencedTable: $$LabelsTableReferences
                          ._personLabelsRefsTable(db),
                      managerFromTypedResult: (p0) => $$LabelsTableReferences(
                        db,
                        table,
                        p0,
                      ).personLabelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.labelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTable,
      Label,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (Label, $$LabelsTableReferences),
      Label,
      PrefetchHooks Function({bool personLabelsRefs})
    >;
typedef $$PersonLabelsTableCreateCompanionBuilder =
    PersonLabelsCompanion Function({
      required int personId,
      required int labelId,
      Value<int> rowid,
    });
typedef $$PersonLabelsTableUpdateCompanionBuilder =
    PersonLabelsCompanion Function({
      Value<int> personId,
      Value<int> labelId,
      Value<int> rowid,
    });

final class $$PersonLabelsTableReferences
    extends BaseReferences<_$AppDatabase, $PersonLabelsTable, PersonLabel> {
  $$PersonLabelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) => db.people.createAlias(
    $_aliasNameGenerator(db.personLabels.personId, db.people.id),
  );

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LabelsTable _labelIdTable(_$AppDatabase db) => db.labels.createAlias(
    $_aliasNameGenerator(db.personLabels.labelId, db.labels.id),
  );

  $$LabelsTableProcessedTableManager get labelId {
    final $_column = $_itemColumn<int>('label_id')!;

    final manager = $$LabelsTableTableManager(
      $_db,
      $_db.labels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_labelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonLabelsTable> {
  $$PersonLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableFilterComposer get labelId {
    final $$LabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableFilterComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonLabelsTable> {
  $$PersonLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableOrderingComposer get labelId {
    final $$LabelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableOrderingComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonLabelsTable> {
  $$PersonLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableAnnotationComposer get labelId {
    final $$LabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonLabelsTable,
          PersonLabel,
          $$PersonLabelsTableFilterComposer,
          $$PersonLabelsTableOrderingComposer,
          $$PersonLabelsTableAnnotationComposer,
          $$PersonLabelsTableCreateCompanionBuilder,
          $$PersonLabelsTableUpdateCompanionBuilder,
          (PersonLabel, $$PersonLabelsTableReferences),
          PersonLabel,
          PrefetchHooks Function({bool personId, bool labelId})
        > {
  $$PersonLabelsTableTableManager(_$AppDatabase db, $PersonLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> personId = const Value.absent(),
                Value<int> labelId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonLabelsCompanion(
                personId: personId,
                labelId: labelId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int personId,
                required int labelId,
                Value<int> rowid = const Value.absent(),
              }) => PersonLabelsCompanion.insert(
                personId: personId,
                labelId: labelId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonLabelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false, labelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$PersonLabelsTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$PersonLabelsTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (labelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.labelId,
                                referencedTable: $$PersonLabelsTableReferences
                                    ._labelIdTable(db),
                                referencedColumn: $$PersonLabelsTableReferences
                                    ._labelIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonLabelsTable,
      PersonLabel,
      $$PersonLabelsTableFilterComposer,
      $$PersonLabelsTableOrderingComposer,
      $$PersonLabelsTableAnnotationComposer,
      $$PersonLabelsTableCreateCompanionBuilder,
      $$PersonLabelsTableUpdateCompanionBuilder,
      (PersonLabel, $$PersonLabelsTableReferences),
      PersonLabel,
      PrefetchHooks Function({bool personId, bool labelId})
    >;
typedef $$InteractionsTableCreateCompanionBuilder =
    InteractionsCompanion Function({
      Value<int> id,
      required int personId,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String> type,
      Value<int?> energyRating,
    });
typedef $$InteractionsTableUpdateCompanionBuilder =
    InteractionsCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String> type,
      Value<int?> energyRating,
    });

final class $$InteractionsTableReferences
    extends BaseReferences<_$AppDatabase, $InteractionsTable, Interaction> {
  $$InteractionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) => db.people.createAlias(
    $_aliasNameGenerator(db.interactions.personId, db.people.id),
  );

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InteractionsTableFilterComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => column,
  );

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InteractionsTable,
          Interaction,
          $$InteractionsTableFilterComposer,
          $$InteractionsTableOrderingComposer,
          $$InteractionsTableAnnotationComposer,
          $$InteractionsTableCreateCompanionBuilder,
          $$InteractionsTableUpdateCompanionBuilder,
          (Interaction, $$InteractionsTableReferences),
          Interaction,
          PrefetchHooks Function({bool personId})
        > {
  $$InteractionsTableTableManager(_$AppDatabase db, $InteractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
              }) => InteractionsCompanion(
                id: id,
                personId: personId,
                date: date,
                notes: notes,
                type: type,
                energyRating: energyRating,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
              }) => InteractionsCompanion.insert(
                id: id,
                personId: personId,
                date: date,
                notes: notes,
                type: type,
                energyRating: energyRating,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InteractionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$InteractionsTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$InteractionsTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InteractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InteractionsTable,
      Interaction,
      $$InteractionsTableFilterComposer,
      $$InteractionsTableOrderingComposer,
      $$InteractionsTableAnnotationComposer,
      $$InteractionsTableCreateCompanionBuilder,
      $$InteractionsTableUpdateCompanionBuilder,
      (Interaction, $$InteractionsTableReferences),
      Interaction,
      PrefetchHooks Function({bool personId})
    >;
typedef $$PersonConnectionsTableCreateCompanionBuilder =
    PersonConnectionsCompanion Function({
      Value<int> id,
      required int personId,
      required int connectedPersonId,
      Value<String> relationLabel,
      Value<DateTime> createdAt,
    });
typedef $$PersonConnectionsTableUpdateCompanionBuilder =
    PersonConnectionsCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<int> connectedPersonId,
      Value<String> relationLabel,
      Value<DateTime> createdAt,
    });

final class $$PersonConnectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonConnectionsTable,
          PersonConnection
        > {
  $$PersonConnectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeopleTable _personIdTable(_$AppDatabase db) => db.people.createAlias(
    $_aliasNameGenerator(db.personConnections.personId, db.people.id),
  );

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PeopleTable _connectedPersonIdTable(_$AppDatabase db) =>
      db.people.createAlias(
        $_aliasNameGenerator(
          db.personConnections.connectedPersonId,
          db.people.id,
        ),
      );

  $$PeopleTableProcessedTableManager get connectedPersonId {
    final $_column = $_itemColumn<int>('connected_person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectedPersonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonConnectionsTable> {
  $$PersonConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableFilterComposer get connectedPersonId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectedPersonId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonConnectionsTable> {
  $$PersonConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableOrderingComposer get connectedPersonId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectedPersonId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonConnectionsTable> {
  $$PersonConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relationLabel => $composableBuilder(
    column: $table.relationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableAnnotationComposer get connectedPersonId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectedPersonId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonConnectionsTable,
          PersonConnection,
          $$PersonConnectionsTableFilterComposer,
          $$PersonConnectionsTableOrderingComposer,
          $$PersonConnectionsTableAnnotationComposer,
          $$PersonConnectionsTableCreateCompanionBuilder,
          $$PersonConnectionsTableUpdateCompanionBuilder,
          (PersonConnection, $$PersonConnectionsTableReferences),
          PersonConnection,
          PrefetchHooks Function({bool personId, bool connectedPersonId})
        > {
  $$PersonConnectionsTableTableManager(
    _$AppDatabase db,
    $PersonConnectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonConnectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<int> connectedPersonId = const Value.absent(),
                Value<String> relationLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonConnectionsCompanion(
                id: id,
                personId: personId,
                connectedPersonId: connectedPersonId,
                relationLabel: relationLabel,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                required int connectedPersonId,
                Value<String> relationLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonConnectionsCompanion.insert(
                id: id,
                personId: personId,
                connectedPersonId: connectedPersonId,
                relationLabel: relationLabel,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonConnectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({personId = false, connectedPersonId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable:
                                        $$PersonConnectionsTableReferences
                                            ._personIdTable(db),
                                    referencedColumn:
                                        $$PersonConnectionsTableReferences
                                            ._personIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (connectedPersonId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.connectedPersonId,
                                    referencedTable:
                                        $$PersonConnectionsTableReferences
                                            ._connectedPersonIdTable(db),
                                    referencedColumn:
                                        $$PersonConnectionsTableReferences
                                            ._connectedPersonIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PersonConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonConnectionsTable,
      PersonConnection,
      $$PersonConnectionsTableFilterComposer,
      $$PersonConnectionsTableOrderingComposer,
      $$PersonConnectionsTableAnnotationComposer,
      $$PersonConnectionsTableCreateCompanionBuilder,
      $$PersonConnectionsTableUpdateCompanionBuilder,
      (PersonConnection, $$PersonConnectionsTableReferences),
      PersonConnection,
      PrefetchHooks Function({bool personId, bool connectedPersonId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$PersonLabelsTableTableManager get personLabels =>
      $$PersonLabelsTableTableManager(_db, _db.personLabels);
  $$InteractionsTableTableManager get interactions =>
      $$InteractionsTableTableManager(_db, _db.interactions);
  $$PersonConnectionsTableTableManager get personConnections =>
      $$PersonConnectionsTableTableManager(_db, _db.personConnections);
}
