// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalSettingsTable extends LocalSettings
    with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  final String key;
  final String value;
  const LocalSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalSetting copyWith({String? key, String? value}) =>
      LocalSetting(key: key ?? this.key, value: value ?? this.value);
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemIdMeta = const VerificationMeta(
    'systemId',
  );
  @override
  late final GeneratedColumn<String> systemId = GeneratedColumn<String>(
    'system_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatsappMeta = const VerificationMeta(
    'whatsapp',
  );
  @override
  late final GeneratedColumn<bool> whatsapp = GeneratedColumn<bool>(
    'whatsapp',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("whatsapp" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Importance?, int> importance =
      GeneratedColumn<int>(
        'importance',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Importance?>($PeopleTable.$converterimportancen);
  static const VerificationMeta _pausedUntilMeta = const VerificationMeta(
    'pausedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> pausedUntil = GeneratedColumn<DateTime>(
    'paused_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    systemId,
    name,
    phone,
    whatsapp,
    importance,
    pausedUntil,
    note,
    archived,
    createdAt,
    updatedAt,
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('system_id')) {
      context.handle(
        _systemIdMeta,
        systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('whatsapp')) {
      context.handle(
        _whatsappMeta,
        whatsapp.isAcceptableOrUnknown(data['whatsapp']!, _whatsappMeta),
      );
    }
    if (data.containsKey('paused_until')) {
      context.handle(
        _pausedUntilMeta,
        pausedUntil.isAcceptableOrUnknown(
          data['paused_until']!,
          _pausedUntilMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      systemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      whatsapp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}whatsapp'],
      )!,
      importance: $PeopleTable.$converterimportancen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}importance'],
        ),
      ),
      pausedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_until'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Importance, int, int> $converterimportance =
      const EnumIndexConverter<Importance>(Importance.values);
  static JsonTypeConverter2<Importance?, int?, int?> $converterimportancen =
      JsonTypeConverter2.asNullable($converterimportance);
}

class Person extends DataClass implements Insertable<Person> {
  final String id;

  /// Schlüssel im Adressbuch des Geräts (Android: Lookup-Key, iOS:
  /// Identifier) zum Abgleich beim erneuten Import; `null` = von Hand.
  final String? systemId;
  final String name;
  final String? phone;

  /// WhatsApp-Knopf anbieten.
  final bool whatsapp;

  /// `null` = noch nicht eingeordnet (wird nicht vorgeschlagen).
  final Importance? importance;

  /// Pausiert bis einschließlich diesem Tag.
  final DateTime? pausedUntil;
  final String? note;

  /// Aus der App entfernt — bleibt, damit ein erneuter Import ihn nicht
  /// wieder hinzufügt und der Verlauf erhalten bleibt.
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Person({
    required this.id,
    this.systemId,
    required this.name,
    this.phone,
    required this.whatsapp,
    this.importance,
    this.pausedUntil,
    this.note,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || systemId != null) {
      map['system_id'] = Variable<String>(systemId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['whatsapp'] = Variable<bool>(whatsapp);
    if (!nullToAbsent || importance != null) {
      map['importance'] = Variable<int>(
        $PeopleTable.$converterimportancen.toSql(importance),
      );
    }
    if (!nullToAbsent || pausedUntil != null) {
      map['paused_until'] = Variable<DateTime>(pausedUntil);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      systemId: systemId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      whatsapp: Value(whatsapp),
      importance: importance == null && nullToAbsent
          ? const Value.absent()
          : Value(importance),
      pausedUntil: pausedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedUntil),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      systemId: serializer.fromJson<String?>(json['systemId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      whatsapp: serializer.fromJson<bool>(json['whatsapp']),
      importance: $PeopleTable.$converterimportancen.fromJson(
        serializer.fromJson<int?>(json['importance']),
      ),
      pausedUntil: serializer.fromJson<DateTime?>(json['pausedUntil']),
      note: serializer.fromJson<String?>(json['note']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'systemId': serializer.toJson<String?>(systemId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'whatsapp': serializer.toJson<bool>(whatsapp),
      'importance': serializer.toJson<int?>(
        $PeopleTable.$converterimportancen.toJson(importance),
      ),
      'pausedUntil': serializer.toJson<DateTime?>(pausedUntil),
      'note': serializer.toJson<String?>(note),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Person copyWith({
    String? id,
    Value<String?> systemId = const Value.absent(),
    String? name,
    Value<String?> phone = const Value.absent(),
    bool? whatsapp,
    Value<Importance?> importance = const Value.absent(),
    Value<DateTime?> pausedUntil = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Person(
    id: id ?? this.id,
    systemId: systemId.present ? systemId.value : this.systemId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    whatsapp: whatsapp ?? this.whatsapp,
    importance: importance.present ? importance.value : this.importance,
    pausedUntil: pausedUntil.present ? pausedUntil.value : this.pausedUntil,
    note: note.present ? note.value : this.note,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Person copyWithCompanion(PeopleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      systemId: data.systemId.present ? data.systemId.value : this.systemId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsapp: data.whatsapp.present ? data.whatsapp.value : this.whatsapp,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      pausedUntil: data.pausedUntil.present
          ? data.pausedUntil.value
          : this.pausedUntil,
      note: data.note.present ? data.note.value : this.note,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('systemId: $systemId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('importance: $importance, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('note: $note, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    systemId,
    name,
    phone,
    whatsapp,
    importance,
    pausedUntil,
    note,
    archived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.systemId == this.systemId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.whatsapp == this.whatsapp &&
          other.importance == this.importance &&
          other.pausedUntil == this.pausedUntil &&
          other.note == this.note &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PeopleCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<String?> systemId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<bool> whatsapp;
  final Value<Importance?> importance;
  final Value<DateTime?> pausedUntil;
  final Value<String?> note;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.systemId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.importance = const Value.absent(),
    this.pausedUntil = const Value.absent(),
    this.note = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    this.systemId = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.importance = const Value.absent(),
    this.pausedUntil = const Value.absent(),
    this.note = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<String>? systemId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<bool>? whatsapp,
    Expression<int>? importance,
    Expression<DateTime>? pausedUntil,
    Expression<String>? note,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systemId != null) 'system_id': systemId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (importance != null) 'importance': importance,
      if (pausedUntil != null) 'paused_until': pausedUntil,
      if (note != null) 'note': note,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String?>? systemId,
    Value<String>? name,
    Value<String?>? phone,
    Value<bool>? whatsapp,
    Value<Importance?>? importance,
    Value<DateTime?>? pausedUntil,
    Value<String?>? note,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      importance: importance ?? this.importance,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      note: note ?? this.note,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<String>(systemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsapp.present) {
      map['whatsapp'] = Variable<bool>(whatsapp.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(
        $PeopleTable.$converterimportancen.toSql(importance.value),
      );
    }
    if (pausedUntil.present) {
      map['paused_until'] = Variable<DateTime>(pausedUntil.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('systemId: $systemId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('importance: $importance, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('note: $note, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactEventsTable extends ContactEvents
    with TableInfo<$ContactEventsTable, ContactEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EventKind>($ContactEventsTable.$converterkind);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestionIdMeta = const VerificationMeta(
    'suggestionId',
  );
  @override
  late final GeneratedColumn<String> suggestionId = GeneratedColumn<String>(
    'suggestion_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, personId, kind, at, suggestionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('suggestion_id')) {
      context.handle(
        _suggestionIdMeta,
        suggestionId.isAcceptableOrUnknown(
          data['suggestion_id']!,
          _suggestionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      kind: $ContactEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      suggestionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggestion_id'],
      ),
    );
  }

  @override
  $ContactEventsTable createAlias(String alias) {
    return $ContactEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EventKind, int, int> $converterkind =
      const EnumIndexConverter<EventKind>(EventKind.values);
}

class ContactEvent extends DataClass implements Insertable<ContactEvent> {
  final String id;
  final String personId;
  final EventKind kind;
  final DateTime at;

  /// Zugehöriger Tagesvorschlag, falls aus einem Vorschlag heraus.
  final String? suggestionId;
  const ContactEvent({
    required this.id,
    required this.personId,
    required this.kind,
    required this.at,
    this.suggestionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    {
      map['kind'] = Variable<int>(
        $ContactEventsTable.$converterkind.toSql(kind),
      );
    }
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || suggestionId != null) {
      map['suggestion_id'] = Variable<String>(suggestionId);
    }
    return map;
  }

  ContactEventsCompanion toCompanion(bool nullToAbsent) {
    return ContactEventsCompanion(
      id: Value(id),
      personId: Value(personId),
      kind: Value(kind),
      at: Value(at),
      suggestionId: suggestionId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestionId),
    );
  }

  factory ContactEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactEvent(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      kind: $ContactEventsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      at: serializer.fromJson<DateTime>(json['at']),
      suggestionId: serializer.fromJson<String?>(json['suggestionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'kind': serializer.toJson<int>(
        $ContactEventsTable.$converterkind.toJson(kind),
      ),
      'at': serializer.toJson<DateTime>(at),
      'suggestionId': serializer.toJson<String?>(suggestionId),
    };
  }

  ContactEvent copyWith({
    String? id,
    String? personId,
    EventKind? kind,
    DateTime? at,
    Value<String?> suggestionId = const Value.absent(),
  }) => ContactEvent(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    kind: kind ?? this.kind,
    at: at ?? this.at,
    suggestionId: suggestionId.present ? suggestionId.value : this.suggestionId,
  );
  ContactEvent copyWithCompanion(ContactEventsCompanion data) {
    return ContactEvent(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      kind: data.kind.present ? data.kind.value : this.kind,
      at: data.at.present ? data.at.value : this.at,
      suggestionId: data.suggestionId.present
          ? data.suggestionId.value
          : this.suggestionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactEvent(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('suggestionId: $suggestionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, kind, at, suggestionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactEvent &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.kind == this.kind &&
          other.at == this.at &&
          other.suggestionId == this.suggestionId);
}

class ContactEventsCompanion extends UpdateCompanion<ContactEvent> {
  final Value<String> id;
  final Value<String> personId;
  final Value<EventKind> kind;
  final Value<DateTime> at;
  final Value<String?> suggestionId;
  final Value<int> rowid;
  const ContactEventsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.kind = const Value.absent(),
    this.at = const Value.absent(),
    this.suggestionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactEventsCompanion.insert({
    required String id,
    required String personId,
    required EventKind kind,
    required DateTime at,
    this.suggestionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       kind = Value(kind),
       at = Value(at);
  static Insertable<ContactEvent> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<int>? kind,
    Expression<DateTime>? at,
    Expression<String>? suggestionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (kind != null) 'kind': kind,
      if (at != null) 'at': at,
      if (suggestionId != null) 'suggestion_id': suggestionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<EventKind>? kind,
    Value<DateTime>? at,
    Value<String?>? suggestionId,
    Value<int>? rowid,
  }) {
    return ContactEventsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      kind: kind ?? this.kind,
      at: at ?? this.at,
      suggestionId: suggestionId ?? this.suggestionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $ContactEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (suggestionId.present) {
      map['suggestion_id'] = Variable<String>(suggestionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactEventsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('suggestionId: $suggestionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailySuggestionsTable extends DailySuggestions
    with TableInfo<$DailySuggestionsTable, DailySuggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SuggestionStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SuggestionStatus>(
        $DailySuggestionsTable.$converterstatus,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, personId, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySuggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailySuggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySuggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      status: $DailySuggestionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailySuggestionsTable createAlias(String alias) {
    return $DailySuggestionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SuggestionStatus, int, int> $converterstatus =
      const EnumIndexConverter<SuggestionStatus>(SuggestionStatus.values);
}

class DailySuggestion extends DataClass implements Insertable<DailySuggestion> {
  final String id;

  /// Tagesschlüssel „2026-10-11“.
  final String day;
  final String personId;
  final SuggestionStatus status;
  final DateTime createdAt;
  const DailySuggestion({
    required this.id,
    required this.day,
    required this.personId,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['person_id'] = Variable<String>(personId);
    {
      map['status'] = Variable<int>(
        $DailySuggestionsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailySuggestionsCompanion toCompanion(bool nullToAbsent) {
    return DailySuggestionsCompanion(
      id: Value(id),
      day: Value(day),
      personId: Value(personId),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DailySuggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySuggestion(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      personId: serializer.fromJson<String>(json['personId']),
      status: $DailySuggestionsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'personId': serializer.toJson<String>(personId),
      'status': serializer.toJson<int>(
        $DailySuggestionsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailySuggestion copyWith({
    String? id,
    String? day,
    String? personId,
    SuggestionStatus? status,
    DateTime? createdAt,
  }) => DailySuggestion(
    id: id ?? this.id,
    day: day ?? this.day,
    personId: personId ?? this.personId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DailySuggestion copyWithCompanion(DailySuggestionsCompanion data) {
    return DailySuggestion(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      personId: data.personId.present ? data.personId.value : this.personId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySuggestion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('personId: $personId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, personId, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySuggestion &&
          other.id == this.id &&
          other.day == this.day &&
          other.personId == this.personId &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DailySuggestionsCompanion extends UpdateCompanion<DailySuggestion> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> personId;
  final Value<SuggestionStatus> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailySuggestionsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.personId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySuggestionsCompanion.insert({
    required String id,
    required String day,
    required String personId,
    required SuggestionStatus status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       personId = Value(personId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DailySuggestion> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? personId,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (personId != null) 'person_id': personId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySuggestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? personId,
    Value<SuggestionStatus>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailySuggestionsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      personId: personId ?? this.personId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $DailySuggestionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('personId: $personId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $ContactEventsTable contactEvents = $ContactEventsTable(this);
  late final $DailySuggestionsTable dailySuggestions = $DailySuggestionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSettings,
    people,
    contactEvents,
    dailySuggestions,
  ];
}

typedef $$LocalSettingsTableCreateCompanionBuilder =
    LocalSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalSettingsTableUpdateCompanionBuilder =
    LocalSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSetting,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (
            LocalSetting,
            BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>,
          ),
          LocalSetting,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSettingsTable, LocalSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalSettingsTable,
                    LocalSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSetting,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (
        LocalSetting,
        BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>,
      ),
      LocalSetting,
      PrefetchHooks Function()
    >;
typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  Value<String?> systemId,
  required String name,
  Value<String?> phone,
  Value<bool> whatsapp,
  Value<Importance?> importance,
  Value<DateTime?> pausedUntil,
  Value<String?> note,
  Value<bool> archived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<String?> systemId,
  Value<String> name,
  Value<String?> phone,
  Value<bool> whatsapp,
  Value<Importance?> importance,
  Value<DateTime?> pausedUntil,
  Value<String?> note,
  Value<bool> archived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemId => $composableBuilder(
    column: $table.systemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Importance?, Importance, int> get importance =>
      $composableBuilder(
        column: $table.importance,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemId => $composableBuilder(
    column: $table.systemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get systemId =>
      $composableBuilder(column: $table.systemId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get whatsapp =>
      $composableBuilder(column: $table.whatsapp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Importance?, int> get importance =>
      $composableBuilder(
        column: $table.importance,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
          (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
          Person,
          PrefetchHooks Function()
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
                Value<String> id = const Value.absent(),
                Value<String?> systemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> whatsapp = const Value.absent(),
                Value<Importance?> importance = const Value.absent(),
                Value<DateTime?> pausedUntil = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                systemId: systemId,
                name: name,
                phone: phone,
                whatsapp: whatsapp,
                importance: importance,
                pausedUntil: pausedUntil,
                note: note,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> systemId = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<bool> whatsapp = const Value.absent(),
                Value<Importance?> importance = const Value.absent(),
                Value<DateTime?> pausedUntil = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                systemId: systemId,
                name: name,
                phone: phone,
                whatsapp: whatsapp,
                importance: importance,
                pausedUntil: pausedUntil,
                note: note,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeopleTable, Person>(table),
                  BaseReferences<_$AppDatabase, $PeopleTable, Person>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
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
      (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
      Person,
      PrefetchHooks Function()
    >;
typedef $$ContactEventsTableCreateCompanionBuilder =
    ContactEventsCompanion Function({
      required String id,
      required String personId,
      required EventKind kind,
      required DateTime at,
      Value<String?> suggestionId,
      Value<int> rowid,
    });
typedef $$ContactEventsTableUpdateCompanionBuilder =
    ContactEventsCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<EventKind> kind,
      Value<DateTime> at,
      Value<String?> suggestionId,
      Value<int> rowid,
    });

class $$ContactEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EventKind, EventKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestionId => $composableBuilder(
    column: $table.suggestionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestionId => $composableBuilder(
    column: $table.suggestionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactEventsTable> {
  $$ContactEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get suggestionId => $composableBuilder(
    column: $table.suggestionId,
    builder: (column) => column,
  );
}

class $$ContactEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactEventsTable,
          ContactEvent,
          $$ContactEventsTableFilterComposer,
          $$ContactEventsTableOrderingComposer,
          $$ContactEventsTableAnnotationComposer,
          $$ContactEventsTableCreateCompanionBuilder,
          $$ContactEventsTableUpdateCompanionBuilder,
          (
            ContactEvent,
            BaseReferences<_$AppDatabase, $ContactEventsTable, ContactEvent>,
          ),
          ContactEvent,
          PrefetchHooks Function()
        > {
  $$ContactEventsTableTableManager(_$AppDatabase db, $ContactEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<EventKind> kind = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String?> suggestionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactEventsCompanion(
                id: id,
                personId: personId,
                kind: kind,
                at: at,
                suggestionId: suggestionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required EventKind kind,
                required DateTime at,
                Value<String?> suggestionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactEventsCompanion.insert(
                id: id,
                personId: personId,
                kind: kind,
                at: at,
                suggestionId: suggestionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactEventsTable, ContactEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContactEventsTable,
                    ContactEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactEventsTable,
      ContactEvent,
      $$ContactEventsTableFilterComposer,
      $$ContactEventsTableOrderingComposer,
      $$ContactEventsTableAnnotationComposer,
      $$ContactEventsTableCreateCompanionBuilder,
      $$ContactEventsTableUpdateCompanionBuilder,
      (
        ContactEvent,
        BaseReferences<_$AppDatabase, $ContactEventsTable, ContactEvent>,
      ),
      ContactEvent,
      PrefetchHooks Function()
    >;
typedef $$DailySuggestionsTableCreateCompanionBuilder =
    DailySuggestionsCompanion Function({
      required String id,
      required String day,
      required String personId,
      required SuggestionStatus status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailySuggestionsTableUpdateCompanionBuilder =
    DailySuggestionsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String> personId,
      Value<SuggestionStatus> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailySuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySuggestionsTable> {
  $$DailySuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SuggestionStatus, SuggestionStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySuggestionsTable> {
  $$DailySuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySuggestionsTable> {
  $$DailySuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SuggestionStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailySuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySuggestionsTable,
          DailySuggestion,
          $$DailySuggestionsTableFilterComposer,
          $$DailySuggestionsTableOrderingComposer,
          $$DailySuggestionsTableAnnotationComposer,
          $$DailySuggestionsTableCreateCompanionBuilder,
          $$DailySuggestionsTableUpdateCompanionBuilder,
          (
            DailySuggestion,
            BaseReferences<
              _$AppDatabase,
              $DailySuggestionsTable,
              DailySuggestion
            >,
          ),
          DailySuggestion,
          PrefetchHooks Function()
        > {
  $$DailySuggestionsTableTableManager(
    _$AppDatabase db,
    $DailySuggestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<SuggestionStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySuggestionsCompanion(
                id: id,
                day: day,
                personId: personId,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required String personId,
                required SuggestionStatus status,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailySuggestionsCompanion.insert(
                id: id,
                day: day,
                personId: personId,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailySuggestionsTable, DailySuggestion>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailySuggestionsTable,
                    DailySuggestion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySuggestionsTable,
      DailySuggestion,
      $$DailySuggestionsTableFilterComposer,
      $$DailySuggestionsTableOrderingComposer,
      $$DailySuggestionsTableAnnotationComposer,
      $$DailySuggestionsTableCreateCompanionBuilder,
      $$DailySuggestionsTableUpdateCompanionBuilder,
      (
        DailySuggestion,
        BaseReferences<_$AppDatabase, $DailySuggestionsTable, DailySuggestion>,
      ),
      DailySuggestion,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$ContactEventsTableTableManager get contactEvents =>
      $$ContactEventsTableTableManager(_db, _db.contactEvents);
  $$DailySuggestionsTableTableManager get dailySuggestions =>
      $$DailySuggestionsTableTableManager(_db, _db.dailySuggestions);
}
