// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BillPlansTable extends BillPlans
    with TableInfo<$BillPlansTable, BillPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountSuffixMeta = const VerificationMeta(
    'accountSuffix',
  );
  @override
  late final GeneratedColumn<String> accountSuffix = GeneratedColumn<String>(
    'account_suffix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountInCentsMeta = const VerificationMeta(
    'amountInCents',
  );
  @override
  late final GeneratedColumn<int> amountInCents = GeneratedColumn<int>(
    'amount_in_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstDueDateMeta = const VerificationMeta(
    'firstDueDate',
  );
  @override
  late final GeneratedColumn<String> firstDueDate = GeneratedColumn<String>(
    'first_due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAutoDebitMeta = const VerificationMeta(
    'isAutoDebit',
  );
  @override
  late final GeneratedColumn<bool> isAutoDebit = GeneratedColumn<bool>(
    'is_auto_debit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_debit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalInstallmentsMeta = const VerificationMeta(
    'totalInstallments',
  );
  @override
  late final GeneratedColumn<int> totalInstallments = GeneratedColumn<int>(
    'total_installments',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    institution,
    accountSuffix,
    amountInCents,
    cycle,
    firstDueDate,
    reminderHour,
    isAutoDebit,
    note,
    totalInstallments,
    status,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionMeta);
    }
    if (data.containsKey('account_suffix')) {
      context.handle(
        _accountSuffixMeta,
        accountSuffix.isAcceptableOrUnknown(
          data['account_suffix']!,
          _accountSuffixMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountSuffixMeta);
    }
    if (data.containsKey('amount_in_cents')) {
      context.handle(
        _amountInCentsMeta,
        amountInCents.isAcceptableOrUnknown(
          data['amount_in_cents']!,
          _amountInCentsMeta,
        ),
      );
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('first_due_date')) {
      context.handle(
        _firstDueDateMeta,
        firstDueDate.isAcceptableOrUnknown(
          data['first_due_date']!,
          _firstDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstDueDateMeta);
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderHourMeta);
    }
    if (data.containsKey('is_auto_debit')) {
      context.handle(
        _isAutoDebitMeta,
        isAutoDebit.isAcceptableOrUnknown(
          data['is_auto_debit']!,
          _isAutoDebitMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('total_installments')) {
      context.handle(
        _totalInstallmentsMeta,
        totalInstallments.isAcceptableOrUnknown(
          data['total_installments']!,
          _totalInstallmentsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      )!,
      accountSuffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_suffix'],
      )!,
      amountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_cents'],
      ),
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      firstDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_due_date'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      isAutoDebit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_debit'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      totalInstallments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_installments'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $BillPlansTable createAlias(String alias) {
    return $BillPlansTable(attachedDatabase, alias);
  }
}

class BillPlan extends DataClass implements Insertable<BillPlan> {
  final String id;
  final String title;
  final String category;
  final String institution;
  final String accountSuffix;
  final int? amountInCents;
  final String cycle;
  final String firstDueDate;
  final int reminderHour;
  final bool isAutoDebit;
  final String note;
  final int? totalInstallments;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const BillPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.institution,
    required this.accountSuffix,
    this.amountInCents,
    required this.cycle,
    required this.firstDueDate,
    required this.reminderHour,
    required this.isAutoDebit,
    required this.note,
    this.totalInstallments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['institution'] = Variable<String>(institution);
    map['account_suffix'] = Variable<String>(accountSuffix);
    if (!nullToAbsent || amountInCents != null) {
      map['amount_in_cents'] = Variable<int>(amountInCents);
    }
    map['cycle'] = Variable<String>(cycle);
    map['first_due_date'] = Variable<String>(firstDueDate);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['is_auto_debit'] = Variable<bool>(isAutoDebit);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || totalInstallments != null) {
      map['total_installments'] = Variable<int>(totalInstallments);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  BillPlansCompanion toCompanion(bool nullToAbsent) {
    return BillPlansCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      institution: Value(institution),
      accountSuffix: Value(accountSuffix),
      amountInCents: amountInCents == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInCents),
      cycle: Value(cycle),
      firstDueDate: Value(firstDueDate),
      reminderHour: Value(reminderHour),
      isAutoDebit: Value(isAutoDebit),
      note: Value(note),
      totalInstallments: totalInstallments == null && nullToAbsent
          ? const Value.absent()
          : Value(totalInstallments),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory BillPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillPlan(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      institution: serializer.fromJson<String>(json['institution']),
      accountSuffix: serializer.fromJson<String>(json['accountSuffix']),
      amountInCents: serializer.fromJson<int?>(json['amountInCents']),
      cycle: serializer.fromJson<String>(json['cycle']),
      firstDueDate: serializer.fromJson<String>(json['firstDueDate']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      isAutoDebit: serializer.fromJson<bool>(json['isAutoDebit']),
      note: serializer.fromJson<String>(json['note']),
      totalInstallments: serializer.fromJson<int?>(json['totalInstallments']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'institution': serializer.toJson<String>(institution),
      'accountSuffix': serializer.toJson<String>(accountSuffix),
      'amountInCents': serializer.toJson<int?>(amountInCents),
      'cycle': serializer.toJson<String>(cycle),
      'firstDueDate': serializer.toJson<String>(firstDueDate),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'isAutoDebit': serializer.toJson<bool>(isAutoDebit),
      'note': serializer.toJson<String>(note),
      'totalInstallments': serializer.toJson<int?>(totalInstallments),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  BillPlan copyWith({
    String? id,
    String? title,
    String? category,
    String? institution,
    String? accountSuffix,
    Value<int?> amountInCents = const Value.absent(),
    String? cycle,
    String? firstDueDate,
    int? reminderHour,
    bool? isAutoDebit,
    String? note,
    Value<int?> totalInstallments = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => BillPlan(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    institution: institution ?? this.institution,
    accountSuffix: accountSuffix ?? this.accountSuffix,
    amountInCents: amountInCents.present
        ? amountInCents.value
        : this.amountInCents,
    cycle: cycle ?? this.cycle,
    firstDueDate: firstDueDate ?? this.firstDueDate,
    reminderHour: reminderHour ?? this.reminderHour,
    isAutoDebit: isAutoDebit ?? this.isAutoDebit,
    note: note ?? this.note,
    totalInstallments: totalInstallments.present
        ? totalInstallments.value
        : this.totalInstallments,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  BillPlan copyWithCompanion(BillPlansCompanion data) {
    return BillPlan(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      accountSuffix: data.accountSuffix.present
          ? data.accountSuffix.value
          : this.accountSuffix,
      amountInCents: data.amountInCents.present
          ? data.amountInCents.value
          : this.amountInCents,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      firstDueDate: data.firstDueDate.present
          ? data.firstDueDate.value
          : this.firstDueDate,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      isAutoDebit: data.isAutoDebit.present
          ? data.isAutoDebit.value
          : this.isAutoDebit,
      note: data.note.present ? data.note.value : this.note,
      totalInstallments: data.totalInstallments.present
          ? data.totalInstallments.value
          : this.totalInstallments,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillPlan(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('institution: $institution, ')
          ..write('accountSuffix: $accountSuffix, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('cycle: $cycle, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('isAutoDebit: $isAutoDebit, ')
          ..write('note: $note, ')
          ..write('totalInstallments: $totalInstallments, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    institution,
    accountSuffix,
    amountInCents,
    cycle,
    firstDueDate,
    reminderHour,
    isAutoDebit,
    note,
    totalInstallments,
    status,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillPlan &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.institution == this.institution &&
          other.accountSuffix == this.accountSuffix &&
          other.amountInCents == this.amountInCents &&
          other.cycle == this.cycle &&
          other.firstDueDate == this.firstDueDate &&
          other.reminderHour == this.reminderHour &&
          other.isAutoDebit == this.isAutoDebit &&
          other.note == this.note &&
          other.totalInstallments == this.totalInstallments &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class BillPlansCompanion extends UpdateCompanion<BillPlan> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<String> institution;
  final Value<String> accountSuffix;
  final Value<int?> amountInCents;
  final Value<String> cycle;
  final Value<String> firstDueDate;
  final Value<int> reminderHour;
  final Value<bool> isAutoDebit;
  final Value<String> note;
  final Value<int?> totalInstallments;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const BillPlansCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.institution = const Value.absent(),
    this.accountSuffix = const Value.absent(),
    this.amountInCents = const Value.absent(),
    this.cycle = const Value.absent(),
    this.firstDueDate = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.isAutoDebit = const Value.absent(),
    this.note = const Value.absent(),
    this.totalInstallments = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillPlansCompanion.insert({
    required String id,
    required String title,
    required String category,
    required String institution,
    required String accountSuffix,
    this.amountInCents = const Value.absent(),
    required String cycle,
    required String firstDueDate,
    required int reminderHour,
    this.isAutoDebit = const Value.absent(),
    required String note,
    this.totalInstallments = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       institution = Value(institution),
       accountSuffix = Value(accountSuffix),
       cycle = Value(cycle),
       firstDueDate = Value(firstDueDate),
       reminderHour = Value(reminderHour),
       note = Value(note),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BillPlan> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? institution,
    Expression<String>? accountSuffix,
    Expression<int>? amountInCents,
    Expression<String>? cycle,
    Expression<String>? firstDueDate,
    Expression<int>? reminderHour,
    Expression<bool>? isAutoDebit,
    Expression<String>? note,
    Expression<int>? totalInstallments,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (institution != null) 'institution': institution,
      if (accountSuffix != null) 'account_suffix': accountSuffix,
      if (amountInCents != null) 'amount_in_cents': amountInCents,
      if (cycle != null) 'cycle': cycle,
      if (firstDueDate != null) 'first_due_date': firstDueDate,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (isAutoDebit != null) 'is_auto_debit': isAutoDebit,
      if (note != null) 'note': note,
      if (totalInstallments != null) 'total_installments': totalInstallments,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<String>? institution,
    Value<String>? accountSuffix,
    Value<int?>? amountInCents,
    Value<String>? cycle,
    Value<String>? firstDueDate,
    Value<int>? reminderHour,
    Value<bool>? isAutoDebit,
    Value<String>? note,
    Value<int?>? totalInstallments,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return BillPlansCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      institution: institution ?? this.institution,
      accountSuffix: accountSuffix ?? this.accountSuffix,
      amountInCents: amountInCents ?? this.amountInCents,
      cycle: cycle ?? this.cycle,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      reminderHour: reminderHour ?? this.reminderHour,
      isAutoDebit: isAutoDebit ?? this.isAutoDebit,
      note: note ?? this.note,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (accountSuffix.present) {
      map['account_suffix'] = Variable<String>(accountSuffix.value);
    }
    if (amountInCents.present) {
      map['amount_in_cents'] = Variable<int>(amountInCents.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (firstDueDate.present) {
      map['first_due_date'] = Variable<String>(firstDueDate.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (isAutoDebit.present) {
      map['is_auto_debit'] = Variable<bool>(isAutoDebit.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (totalInstallments.present) {
      map['total_installments'] = Variable<int>(totalInstallments.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillPlansCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('institution: $institution, ')
          ..write('accountSuffix: $accountSuffix, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('cycle: $cycle, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('isAutoDebit: $isAutoDebit, ')
          ..write('note: $note, ')
          ..write('totalInstallments: $totalInstallments, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillPeriodsTable extends BillPeriods
    with TableInfo<$BillPeriodsTable, BillPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bill_plans (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountSuffixMeta = const VerificationMeta(
    'accountSuffix',
  );
  @override
  late final GeneratedColumn<String> accountSuffix = GeneratedColumn<String>(
    'account_suffix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountInCentsMeta = const VerificationMeta(
    'amountInCents',
  );
  @override
  late final GeneratedColumn<int> amountInCents = GeneratedColumn<int>(
    'amount_in_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderDaysMeta = const VerificationMeta(
    'reminderDays',
  );
  @override
  late final GeneratedColumn<String> reminderDays = GeneratedColumn<String>(
    'reminder_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAutoDebitMeta = const VerificationMeta(
    'isAutoDebit',
  );
  @override
  late final GeneratedColumn<bool> isAutoDebit = GeneratedColumn<bool>(
    'is_auto_debit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_debit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalInstallmentsMeta = const VerificationMeta(
    'totalInstallments',
  );
  @override
  late final GeneratedColumn<int> totalInstallments = GeneratedColumn<int>(
    'total_installments',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
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
    planId,
    periodKey,
    sequence,
    title,
    category,
    institution,
    accountSuffix,
    amountInCents,
    cycle,
    dueDate,
    reminderDays,
    reminderHour,
    isAutoDebit,
    note,
    totalInstallments,
    status,
    paidAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionMeta);
    }
    if (data.containsKey('account_suffix')) {
      context.handle(
        _accountSuffixMeta,
        accountSuffix.isAcceptableOrUnknown(
          data['account_suffix']!,
          _accountSuffixMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountSuffixMeta);
    }
    if (data.containsKey('amount_in_cents')) {
      context.handle(
        _amountInCentsMeta,
        amountInCents.isAcceptableOrUnknown(
          data['amount_in_cents']!,
          _amountInCentsMeta,
        ),
      );
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('reminder_days')) {
      context.handle(
        _reminderDaysMeta,
        reminderDays.isAcceptableOrUnknown(
          data['reminder_days']!,
          _reminderDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderDaysMeta);
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderHourMeta);
    }
    if (data.containsKey('is_auto_debit')) {
      context.handle(
        _isAutoDebitMeta,
        isAutoDebit.isAcceptableOrUnknown(
          data['is_auto_debit']!,
          _isAutoDebitMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('total_installments')) {
      context.handle(
        _totalInstallmentsMeta,
        totalInstallments.isAcceptableOrUnknown(
          data['total_installments']!,
          _totalInstallmentsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {planId, periodKey},
  ];
  @override
  BillPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      )!,
      accountSuffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_suffix'],
      )!,
      amountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_cents'],
      ),
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      reminderDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_days'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      isAutoDebit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_debit'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      totalInstallments: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_installments'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
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
  $BillPeriodsTable createAlias(String alias) {
    return $BillPeriodsTable(attachedDatabase, alias);
  }
}

class BillPeriod extends DataClass implements Insertable<BillPeriod> {
  final String id;
  final String planId;
  final String periodKey;
  final int sequence;
  final String title;
  final String category;
  final String institution;
  final String accountSuffix;
  final int? amountInCents;
  final String cycle;
  final String dueDate;
  final String reminderDays;
  final int reminderHour;
  final bool isAutoDebit;
  final String note;
  final int? totalInstallments;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BillPeriod({
    required this.id,
    required this.planId,
    required this.periodKey,
    required this.sequence,
    required this.title,
    required this.category,
    required this.institution,
    required this.accountSuffix,
    this.amountInCents,
    required this.cycle,
    required this.dueDate,
    required this.reminderDays,
    required this.reminderHour,
    required this.isAutoDebit,
    required this.note,
    this.totalInstallments,
    required this.status,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['period_key'] = Variable<String>(periodKey);
    map['sequence'] = Variable<int>(sequence);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['institution'] = Variable<String>(institution);
    map['account_suffix'] = Variable<String>(accountSuffix);
    if (!nullToAbsent || amountInCents != null) {
      map['amount_in_cents'] = Variable<int>(amountInCents);
    }
    map['cycle'] = Variable<String>(cycle);
    map['due_date'] = Variable<String>(dueDate);
    map['reminder_days'] = Variable<String>(reminderDays);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['is_auto_debit'] = Variable<bool>(isAutoDebit);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || totalInstallments != null) {
      map['total_installments'] = Variable<int>(totalInstallments);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BillPeriodsCompanion toCompanion(bool nullToAbsent) {
    return BillPeriodsCompanion(
      id: Value(id),
      planId: Value(planId),
      periodKey: Value(periodKey),
      sequence: Value(sequence),
      title: Value(title),
      category: Value(category),
      institution: Value(institution),
      accountSuffix: Value(accountSuffix),
      amountInCents: amountInCents == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInCents),
      cycle: Value(cycle),
      dueDate: Value(dueDate),
      reminderDays: Value(reminderDays),
      reminderHour: Value(reminderHour),
      isAutoDebit: Value(isAutoDebit),
      note: Value(note),
      totalInstallments: totalInstallments == null && nullToAbsent
          ? const Value.absent()
          : Value(totalInstallments),
      status: Value(status),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BillPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillPeriod(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      sequence: serializer.fromJson<int>(json['sequence']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      institution: serializer.fromJson<String>(json['institution']),
      accountSuffix: serializer.fromJson<String>(json['accountSuffix']),
      amountInCents: serializer.fromJson<int?>(json['amountInCents']),
      cycle: serializer.fromJson<String>(json['cycle']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      reminderDays: serializer.fromJson<String>(json['reminderDays']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      isAutoDebit: serializer.fromJson<bool>(json['isAutoDebit']),
      note: serializer.fromJson<String>(json['note']),
      totalInstallments: serializer.fromJson<int?>(json['totalInstallments']),
      status: serializer.fromJson<String>(json['status']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'periodKey': serializer.toJson<String>(periodKey),
      'sequence': serializer.toJson<int>(sequence),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'institution': serializer.toJson<String>(institution),
      'accountSuffix': serializer.toJson<String>(accountSuffix),
      'amountInCents': serializer.toJson<int?>(amountInCents),
      'cycle': serializer.toJson<String>(cycle),
      'dueDate': serializer.toJson<String>(dueDate),
      'reminderDays': serializer.toJson<String>(reminderDays),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'isAutoDebit': serializer.toJson<bool>(isAutoDebit),
      'note': serializer.toJson<String>(note),
      'totalInstallments': serializer.toJson<int?>(totalInstallments),
      'status': serializer.toJson<String>(status),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BillPeriod copyWith({
    String? id,
    String? planId,
    String? periodKey,
    int? sequence,
    String? title,
    String? category,
    String? institution,
    String? accountSuffix,
    Value<int?> amountInCents = const Value.absent(),
    String? cycle,
    String? dueDate,
    String? reminderDays,
    int? reminderHour,
    bool? isAutoDebit,
    String? note,
    Value<int?> totalInstallments = const Value.absent(),
    String? status,
    Value<DateTime?> paidAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BillPeriod(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    periodKey: periodKey ?? this.periodKey,
    sequence: sequence ?? this.sequence,
    title: title ?? this.title,
    category: category ?? this.category,
    institution: institution ?? this.institution,
    accountSuffix: accountSuffix ?? this.accountSuffix,
    amountInCents: amountInCents.present
        ? amountInCents.value
        : this.amountInCents,
    cycle: cycle ?? this.cycle,
    dueDate: dueDate ?? this.dueDate,
    reminderDays: reminderDays ?? this.reminderDays,
    reminderHour: reminderHour ?? this.reminderHour,
    isAutoDebit: isAutoDebit ?? this.isAutoDebit,
    note: note ?? this.note,
    totalInstallments: totalInstallments.present
        ? totalInstallments.value
        : this.totalInstallments,
    status: status ?? this.status,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BillPeriod copyWithCompanion(BillPeriodsCompanion data) {
    return BillPeriod(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      accountSuffix: data.accountSuffix.present
          ? data.accountSuffix.value
          : this.accountSuffix,
      amountInCents: data.amountInCents.present
          ? data.amountInCents.value
          : this.amountInCents,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      reminderDays: data.reminderDays.present
          ? data.reminderDays.value
          : this.reminderDays,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      isAutoDebit: data.isAutoDebit.present
          ? data.isAutoDebit.value
          : this.isAutoDebit,
      note: data.note.present ? data.note.value : this.note,
      totalInstallments: data.totalInstallments.present
          ? data.totalInstallments.value
          : this.totalInstallments,
      status: data.status.present ? data.status.value : this.status,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillPeriod(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('periodKey: $periodKey, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('institution: $institution, ')
          ..write('accountSuffix: $accountSuffix, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('cycle: $cycle, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderDays: $reminderDays, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('isAutoDebit: $isAutoDebit, ')
          ..write('note: $note, ')
          ..write('totalInstallments: $totalInstallments, ')
          ..write('status: $status, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    periodKey,
    sequence,
    title,
    category,
    institution,
    accountSuffix,
    amountInCents,
    cycle,
    dueDate,
    reminderDays,
    reminderHour,
    isAutoDebit,
    note,
    totalInstallments,
    status,
    paidAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillPeriod &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.periodKey == this.periodKey &&
          other.sequence == this.sequence &&
          other.title == this.title &&
          other.category == this.category &&
          other.institution == this.institution &&
          other.accountSuffix == this.accountSuffix &&
          other.amountInCents == this.amountInCents &&
          other.cycle == this.cycle &&
          other.dueDate == this.dueDate &&
          other.reminderDays == this.reminderDays &&
          other.reminderHour == this.reminderHour &&
          other.isAutoDebit == this.isAutoDebit &&
          other.note == this.note &&
          other.totalInstallments == this.totalInstallments &&
          other.status == this.status &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BillPeriodsCompanion extends UpdateCompanion<BillPeriod> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> periodKey;
  final Value<int> sequence;
  final Value<String> title;
  final Value<String> category;
  final Value<String> institution;
  final Value<String> accountSuffix;
  final Value<int?> amountInCents;
  final Value<String> cycle;
  final Value<String> dueDate;
  final Value<String> reminderDays;
  final Value<int> reminderHour;
  final Value<bool> isAutoDebit;
  final Value<String> note;
  final Value<int?> totalInstallments;
  final Value<String> status;
  final Value<DateTime?> paidAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BillPeriodsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.sequence = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.institution = const Value.absent(),
    this.accountSuffix = const Value.absent(),
    this.amountInCents = const Value.absent(),
    this.cycle = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.reminderDays = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.isAutoDebit = const Value.absent(),
    this.note = const Value.absent(),
    this.totalInstallments = const Value.absent(),
    this.status = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillPeriodsCompanion.insert({
    required String id,
    required String planId,
    required String periodKey,
    required int sequence,
    required String title,
    required String category,
    required String institution,
    required String accountSuffix,
    this.amountInCents = const Value.absent(),
    required String cycle,
    required String dueDate,
    required String reminderDays,
    required int reminderHour,
    this.isAutoDebit = const Value.absent(),
    required String note,
    this.totalInstallments = const Value.absent(),
    this.status = const Value.absent(),
    this.paidAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       periodKey = Value(periodKey),
       sequence = Value(sequence),
       title = Value(title),
       category = Value(category),
       institution = Value(institution),
       accountSuffix = Value(accountSuffix),
       cycle = Value(cycle),
       dueDate = Value(dueDate),
       reminderDays = Value(reminderDays),
       reminderHour = Value(reminderHour),
       note = Value(note),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BillPeriod> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? periodKey,
    Expression<int>? sequence,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? institution,
    Expression<String>? accountSuffix,
    Expression<int>? amountInCents,
    Expression<String>? cycle,
    Expression<String>? dueDate,
    Expression<String>? reminderDays,
    Expression<int>? reminderHour,
    Expression<bool>? isAutoDebit,
    Expression<String>? note,
    Expression<int>? totalInstallments,
    Expression<String>? status,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (periodKey != null) 'period_key': periodKey,
      if (sequence != null) 'sequence': sequence,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (institution != null) 'institution': institution,
      if (accountSuffix != null) 'account_suffix': accountSuffix,
      if (amountInCents != null) 'amount_in_cents': amountInCents,
      if (cycle != null) 'cycle': cycle,
      if (dueDate != null) 'due_date': dueDate,
      if (reminderDays != null) 'reminder_days': reminderDays,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (isAutoDebit != null) 'is_auto_debit': isAutoDebit,
      if (note != null) 'note': note,
      if (totalInstallments != null) 'total_installments': totalInstallments,
      if (status != null) 'status': status,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillPeriodsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<String>? periodKey,
    Value<int>? sequence,
    Value<String>? title,
    Value<String>? category,
    Value<String>? institution,
    Value<String>? accountSuffix,
    Value<int?>? amountInCents,
    Value<String>? cycle,
    Value<String>? dueDate,
    Value<String>? reminderDays,
    Value<int>? reminderHour,
    Value<bool>? isAutoDebit,
    Value<String>? note,
    Value<int?>? totalInstallments,
    Value<String>? status,
    Value<DateTime?>? paidAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BillPeriodsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      periodKey: periodKey ?? this.periodKey,
      sequence: sequence ?? this.sequence,
      title: title ?? this.title,
      category: category ?? this.category,
      institution: institution ?? this.institution,
      accountSuffix: accountSuffix ?? this.accountSuffix,
      amountInCents: amountInCents ?? this.amountInCents,
      cycle: cycle ?? this.cycle,
      dueDate: dueDate ?? this.dueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderHour: reminderHour ?? this.reminderHour,
      isAutoDebit: isAutoDebit ?? this.isAutoDebit,
      note: note ?? this.note,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
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
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (accountSuffix.present) {
      map['account_suffix'] = Variable<String>(accountSuffix.value);
    }
    if (amountInCents.present) {
      map['amount_in_cents'] = Variable<int>(amountInCents.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (reminderDays.present) {
      map['reminder_days'] = Variable<String>(reminderDays.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (isAutoDebit.present) {
      map['is_auto_debit'] = Variable<bool>(isAutoDebit.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (totalInstallments.present) {
      map['total_installments'] = Variable<int>(totalInstallments.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
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
    return (StringBuffer('BillPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('periodKey: $periodKey, ')
          ..write('sequence: $sequence, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('institution: $institution, ')
          ..write('accountSuffix: $accountSuffix, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('cycle: $cycle, ')
          ..write('dueDate: $dueDate, ')
          ..write('reminderDays: $reminderDays, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('isAutoDebit: $isAutoDebit, ')
          ..write('note: $note, ')
          ..write('totalInstallments: $totalInstallments, ')
          ..write('status: $status, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bill_plans (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _daysBeforeDueMeta = const VerificationMeta(
    'daysBeforeDue',
  );
  @override
  late final GeneratedColumn<int> daysBeforeDue = GeneratedColumn<int>(
    'days_before_due',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localHourMeta = const VerificationMeta(
    'localHour',
  );
  @override
  late final GeneratedColumn<int> localHour = GeneratedColumn<int>(
    'local_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localMinuteMeta = const VerificationMeta(
    'localMinute',
  );
  @override
  late final GeneratedColumn<int> localMinute = GeneratedColumn<int>(
    'local_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    planId,
    daysBeforeDue,
    localHour,
    localMinute,
    sortOrder,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('days_before_due')) {
      context.handle(
        _daysBeforeDueMeta,
        daysBeforeDue.isAcceptableOrUnknown(
          data['days_before_due']!,
          _daysBeforeDueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysBeforeDueMeta);
    }
    if (data.containsKey('local_hour')) {
      context.handle(
        _localHourMeta,
        localHour.isAcceptableOrUnknown(data['local_hour']!, _localHourMeta),
      );
    } else if (isInserting) {
      context.missing(_localHourMeta);
    }
    if (data.containsKey('local_minute')) {
      context.handle(
        _localMinuteMeta,
        localMinute.isAcceptableOrUnknown(
          data['local_minute']!,
          _localMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localMinuteMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {planId, daysBeforeDue},
  ];
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      daysBeforeDue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_before_due'],
      )!,
      localHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_hour'],
      )!,
      localMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_minute'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
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
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final String id;
  final String planId;
  final int daysBeforeDue;
  final int localHour;
  final int localMinute;
  final int sortOrder;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderRule({
    required this.id,
    required this.planId,
    required this.daysBeforeDue,
    required this.localHour,
    required this.localMinute,
    required this.sortOrder,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['days_before_due'] = Variable<int>(daysBeforeDue);
    map['local_hour'] = Variable<int>(localHour);
    map['local_minute'] = Variable<int>(localMinute);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      planId: Value(planId),
      daysBeforeDue: Value(daysBeforeDue),
      localHour: Value(localHour),
      localMinute: Value(localMinute),
      sortOrder: Value(sortOrder),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      daysBeforeDue: serializer.fromJson<int>(json['daysBeforeDue']),
      localHour: serializer.fromJson<int>(json['localHour']),
      localMinute: serializer.fromJson<int>(json['localMinute']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'daysBeforeDue': serializer.toJson<int>(daysBeforeDue),
      'localHour': serializer.toJson<int>(localHour),
      'localMinute': serializer.toJson<int>(localMinute),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRule copyWith({
    String? id,
    String? planId,
    int? daysBeforeDue,
    int? localHour,
    int? localMinute,
    int? sortOrder,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReminderRule(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
    localHour: localHour ?? this.localHour,
    localMinute: localMinute ?? this.localMinute,
    sortOrder: sortOrder ?? this.sortOrder,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      daysBeforeDue: data.daysBeforeDue.present
          ? data.daysBeforeDue.value
          : this.daysBeforeDue,
      localHour: data.localHour.present ? data.localHour.value : this.localHour,
      localMinute: data.localMinute.present
          ? data.localMinute.value
          : this.localMinute,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('daysBeforeDue: $daysBeforeDue, ')
          ..write('localHour: $localHour, ')
          ..write('localMinute: $localMinute, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    daysBeforeDue,
    localHour,
    localMinute,
    sortOrder,
    isEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.daysBeforeDue == this.daysBeforeDue &&
          other.localHour == this.localHour &&
          other.localMinute == this.localMinute &&
          other.sortOrder == this.sortOrder &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> daysBeforeDue;
  final Value<int> localHour;
  final Value<int> localMinute;
  final Value<int> sortOrder;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.daysBeforeDue = const Value.absent(),
    this.localHour = const Value.absent(),
    this.localMinute = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    required String id,
    required String planId,
    required int daysBeforeDue,
    required int localHour,
    required int localMinute,
    required int sortOrder,
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       daysBeforeDue = Value(daysBeforeDue),
       localHour = Value(localHour),
       localMinute = Value(localMinute),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRule> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? daysBeforeDue,
    Expression<int>? localHour,
    Expression<int>? localMinute,
    Expression<int>? sortOrder,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (daysBeforeDue != null) 'days_before_due': daysBeforeDue,
      if (localHour != null) 'local_hour': localHour,
      if (localMinute != null) 'local_minute': localMinute,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? daysBeforeDue,
    Value<int>? localHour,
    Value<int>? localMinute,
    Value<int>? sortOrder,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
      localHour: localHour ?? this.localHour,
      localMinute: localMinute ?? this.localMinute,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
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
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (daysBeforeDue.present) {
      map['days_before_due'] = Variable<int>(daysBeforeDue.value);
    }
    if (localHour.present) {
      map['local_hour'] = Variable<int>(localHour.value);
    }
    if (localMinute.present) {
      map['local_minute'] = Variable<int>(localMinute.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
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
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('daysBeforeDue: $daysBeforeDue, ')
          ..write('localHour: $localHour, ')
          ..write('localMinute: $localMinute, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationSchedulesTable extends NotificationSchedules
    with TableInfo<$NotificationSchedulesTable, NotificationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<String> periodId = GeneratedColumn<String>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bill_periods (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _reminderRuleIdMeta = const VerificationMeta(
    'reminderRuleId',
  );
  @override
  late final GeneratedColumn<String> reminderRuleId = GeneratedColumn<String>(
    'reminder_rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminder_rules (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    periodId,
    reminderRuleId,
    fireAt,
    status,
    providerId,
    scheduledAt,
    cancelledAt,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('reminder_rule_id')) {
      context.handle(
        _reminderRuleIdMeta,
        reminderRuleId.isAcceptableOrUnknown(
          data['reminder_rule_id']!,
          _reminderRuleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderRuleIdMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {periodId, reminderRuleId},
  ];
  @override
  NotificationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_id'],
      )!,
      reminderRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_rule_id'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
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
  $NotificationSchedulesTable createAlias(String alias) {
    return $NotificationSchedulesTable(attachedDatabase, alias);
  }
}

class NotificationSchedule extends DataClass
    implements Insertable<NotificationSchedule> {
  final String id;
  final String periodId;
  final String reminderRuleId;
  final DateTime fireAt;
  final String status;
  final String? providerId;
  final DateTime? scheduledAt;
  final DateTime? cancelledAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NotificationSchedule({
    required this.id,
    required this.periodId,
    required this.reminderRuleId,
    required this.fireAt,
    required this.status,
    this.providerId,
    this.scheduledAt,
    this.cancelledAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['period_id'] = Variable<String>(periodId);
    map['reminder_rule_id'] = Variable<String>(reminderRuleId);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotificationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return NotificationSchedulesCompanion(
      id: Value(id),
      periodId: Value(periodId),
      reminderRuleId: Value(reminderRuleId),
      fireAt: Value(fireAt),
      status: Value(status),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotificationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSchedule(
      id: serializer.fromJson<String>(json['id']),
      periodId: serializer.fromJson<String>(json['periodId']),
      reminderRuleId: serializer.fromJson<String>(json['reminderRuleId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      status: serializer.fromJson<String>(json['status']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'periodId': serializer.toJson<String>(periodId),
      'reminderRuleId': serializer.toJson<String>(reminderRuleId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'status': serializer.toJson<String>(status),
      'providerId': serializer.toJson<String?>(providerId),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotificationSchedule copyWith({
    String? id,
    String? periodId,
    String? reminderRuleId,
    DateTime? fireAt,
    String? status,
    Value<String?> providerId = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NotificationSchedule(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    reminderRuleId: reminderRuleId ?? this.reminderRuleId,
    fireAt: fireAt ?? this.fireAt,
    status: status ?? this.status,
    providerId: providerId.present ? providerId.value : this.providerId,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NotificationSchedule copyWithCompanion(NotificationSchedulesCompanion data) {
    return NotificationSchedule(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      reminderRuleId: data.reminderRuleId.present
          ? data.reminderRuleId.value
          : this.reminderRuleId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      status: data.status.present ? data.status.value : this.status,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSchedule(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('reminderRuleId: $reminderRuleId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    periodId,
    reminderRuleId,
    fireAt,
    status,
    providerId,
    scheduledAt,
    cancelledAt,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSchedule &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.reminderRuleId == this.reminderRuleId &&
          other.fireAt == this.fireAt &&
          other.status == this.status &&
          other.providerId == this.providerId &&
          other.scheduledAt == this.scheduledAt &&
          other.cancelledAt == this.cancelledAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotificationSchedulesCompanion
    extends UpdateCompanion<NotificationSchedule> {
  final Value<String> id;
  final Value<String> periodId;
  final Value<String> reminderRuleId;
  final Value<DateTime> fireAt;
  final Value<String> status;
  final Value<String?> providerId;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> cancelledAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotificationSchedulesCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.reminderRuleId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.status = const Value.absent(),
    this.providerId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSchedulesCompanion.insert({
    required String id,
    required String periodId,
    required String reminderRuleId,
    required DateTime fireAt,
    this.status = const Value.absent(),
    this.providerId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       periodId = Value(periodId),
       reminderRuleId = Value(reminderRuleId),
       fireAt = Value(fireAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotificationSchedule> custom({
    Expression<String>? id,
    Expression<String>? periodId,
    Expression<String>? reminderRuleId,
    Expression<DateTime>? fireAt,
    Expression<String>? status,
    Expression<String>? providerId,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? cancelledAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (reminderRuleId != null) 'reminder_rule_id': reminderRuleId,
      if (fireAt != null) 'fire_at': fireAt,
      if (status != null) 'status': status,
      if (providerId != null) 'provider_id': providerId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? periodId,
    Value<String>? reminderRuleId,
    Value<DateTime>? fireAt,
    Value<String>? status,
    Value<String?>? providerId,
    Value<DateTime?>? scheduledAt,
    Value<DateTime?>? cancelledAt,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotificationSchedulesCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      reminderRuleId: reminderRuleId ?? this.reminderRuleId,
      fireAt: fireAt ?? this.fireAt,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      lastError: lastError ?? this.lastError,
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
    if (periodId.present) {
      map['period_id'] = Variable<String>(periodId.value);
    }
    if (reminderRuleId.present) {
      map['reminder_rule_id'] = Variable<String>(reminderRuleId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
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
    return (StringBuffer('NotificationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('reminderRuleId: $reminderRuleId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('providerId: $providerId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BillPlansTable billPlans = $BillPlansTable(this);
  late final $BillPeriodsTable billPeriods = $BillPeriodsTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  late final $NotificationSchedulesTable notificationSchedules =
      $NotificationSchedulesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    billPlans,
    billPeriods,
    reminderRules,
    notificationSchedules,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bill_plans',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('bill_periods', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bill_plans',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('reminder_rules', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bill_periods',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('notification_schedules', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reminder_rules',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('notification_schedules', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$BillPlansTableCreateCompanionBuilder = BillPlansCompanion Function({
  required String id,
  required String title,
  required String category,
  required String institution,
  required String accountSuffix,
  Value<int?> amountInCents,
  required String cycle,
  required String firstDueDate,
  required int reminderHour,
  Value<bool> isAutoDebit,
  required String note,
  Value<int?> totalInstallments,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$BillPlansTableUpdateCompanionBuilder = BillPlansCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> category,
  Value<String> institution,
  Value<String> accountSuffix,
  Value<int?> amountInCents,
  Value<String> cycle,
  Value<String> firstDueDate,
  Value<int> reminderHour,
  Value<bool> isAutoDebit,
  Value<String> note,
  Value<int?> totalInstallments,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$BillPlansTableReferences
    extends BaseReferences<_$AppDatabase, $BillPlansTable, BillPlan> {
  $$BillPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BillPeriodsTable, List<BillPeriod>>
  _billPeriodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.billPeriods,
    aliasName: 'bill_plans__id__bill_periods__plan_id',
  );

  $$BillPeriodsTableProcessedTableManager get billPeriodsRefs {
    final manager = $$BillPeriodsTableTableManager(
      $_db,
      $_db.billPeriods,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_billPeriodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'bill_plans__id__reminder_rules__plan_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillPlansTableFilterComposer
    extends Composer<_$AppDatabase, $BillPlansTable> {
  $$BillPlansTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstDueDate => $composableBuilder(
    column: $table.firstDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> billPeriodsRefs(
    Expression<bool> Function($$BillPeriodsTableFilterComposer f) f,
  ) {
    final $$BillPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billPeriods,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.billPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $BillPlansTable> {
  $$BillPlansTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDueDate => $composableBuilder(
    column: $table.firstDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillPlansTable> {
  $$BillPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<String> get firstDueDate => $composableBuilder(
    column: $table.firstDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> billPeriodsRefs<T extends Object>(
    Expression<T> Function($$BillPeriodsTableAnnotationComposer a) f,
  ) {
    final $$BillPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billPeriods,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.billPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillPlansTable,
          BillPlan,
          $$BillPlansTableFilterComposer,
          $$BillPlansTableOrderingComposer,
          $$BillPlansTableAnnotationComposer,
          $$BillPlansTableCreateCompanionBuilder,
          $$BillPlansTableUpdateCompanionBuilder,
          (BillPlan, $$BillPlansTableReferences),
          BillPlan,
          PrefetchHooks Function({bool billPeriodsRefs, bool reminderRulesRefs})
        > {
  $$BillPlansTableTableManager(_$AppDatabase db, $BillPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> institution = const Value.absent(),
                Value<String> accountSuffix = const Value.absent(),
                Value<int?> amountInCents = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<String> firstDueDate = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<bool> isAutoDebit = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int?> totalInstallments = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillPlansCompanion(
                id: id,
                title: title,
                category: category,
                institution: institution,
                accountSuffix: accountSuffix,
                amountInCents: amountInCents,
                cycle: cycle,
                firstDueDate: firstDueDate,
                reminderHour: reminderHour,
                isAutoDebit: isAutoDebit,
                note: note,
                totalInstallments: totalInstallments,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required String institution,
                required String accountSuffix,
                Value<int?> amountInCents = const Value.absent(),
                required String cycle,
                required String firstDueDate,
                required int reminderHour,
                Value<bool> isAutoDebit = const Value.absent(),
                required String note,
                Value<int?> totalInstallments = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillPlansCompanion.insert(
                id: id,
                title: title,
                category: category,
                institution: institution,
                accountSuffix: accountSuffix,
                amountInCents: amountInCents,
                cycle: cycle,
                firstDueDate: firstDueDate,
                reminderHour: reminderHour,
                isAutoDebit: isAutoDebit,
                note: note,
                totalInstallments: totalInstallments,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BillPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({billPeriodsRefs = false, reminderRulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (billPeriodsRefs) db.billPeriods,
                    if (reminderRulesRefs) db.reminderRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (billPeriodsRefs)
                        await $_getPrefetchedData<
                          BillPlan,
                          $BillPlansTable,
                          BillPeriod
                        >(
                          currentTable: table,
                          referencedTable: $$BillPlansTableReferences
                              ._billPeriodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).billPeriodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderRulesRefs)
                        await $_getPrefetchedData<
                          BillPlan,
                          $BillPlansTable,
                          ReminderRule
                        >(
                          currentTable: table,
                          referencedTable: $$BillPlansTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
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

typedef $$BillPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillPlansTable,
      BillPlan,
      $$BillPlansTableFilterComposer,
      $$BillPlansTableOrderingComposer,
      $$BillPlansTableAnnotationComposer,
      $$BillPlansTableCreateCompanionBuilder,
      $$BillPlansTableUpdateCompanionBuilder,
      (BillPlan, $$BillPlansTableReferences),
      BillPlan,
      PrefetchHooks Function({bool billPeriodsRefs, bool reminderRulesRefs})
    >;
typedef $$BillPeriodsTableCreateCompanionBuilder =
    BillPeriodsCompanion Function({
      required String id,
      required String planId,
      required String periodKey,
      required int sequence,
      required String title,
      required String category,
      required String institution,
      required String accountSuffix,
      Value<int?> amountInCents,
      required String cycle,
      required String dueDate,
      required String reminderDays,
      required int reminderHour,
      Value<bool> isAutoDebit,
      required String note,
      Value<int?> totalInstallments,
      Value<String> status,
      Value<DateTime?> paidAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BillPeriodsTableUpdateCompanionBuilder =
    BillPeriodsCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<String> periodKey,
      Value<int> sequence,
      Value<String> title,
      Value<String> category,
      Value<String> institution,
      Value<String> accountSuffix,
      Value<int?> amountInCents,
      Value<String> cycle,
      Value<String> dueDate,
      Value<String> reminderDays,
      Value<int> reminderHour,
      Value<bool> isAutoDebit,
      Value<String> note,
      Value<int?> totalInstallments,
      Value<String> status,
      Value<DateTime?> paidAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$BillPeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $BillPeriodsTable, BillPeriod> {
  $$BillPeriodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BillPlansTable _planIdTable(_$AppDatabase db) =>
      db.billPlans.createAlias('bill_periods__plan_id__bill_plans__id');

  $$BillPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$BillPlansTableTableManager(
      $_db,
      $_db.billPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $NotificationSchedulesTable,
    List<NotificationSchedule>
  >
  _notificationSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.notificationSchedules,
        aliasName: 'bill_periods__id__notification_schedules__period_id',
      );

  $$NotificationSchedulesTableProcessedTableManager
  get notificationSchedulesRefs {
    final manager = $$NotificationSchedulesTableTableManager(
      $_db,
      $_db.notificationSchedules,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $BillPeriodsTable> {
  $$BillPeriodsTableFilterComposer({
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

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
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

  $$BillPlansTableFilterComposer get planId {
    final $$BillPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableFilterComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> notificationSchedulesRefs(
    Expression<bool> Function($$NotificationSchedulesTableFilterComposer f) f,
  ) {
    final $$NotificationSchedulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationSchedules,
          getReferencedColumn: (t) => t.periodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationSchedulesTableFilterComposer(
                $db: $db,
                $table: $db.notificationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BillPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillPeriodsTable> {
  $$BillPeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
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

  $$BillPlansTableOrderingComposer get planId {
    final $$BillPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableOrderingComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillPeriodsTable> {
  $$BillPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountSuffix => $composableBuilder(
    column: $table.accountSuffix,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get reminderDays => $composableBuilder(
    column: $table.reminderDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAutoDebit => $composableBuilder(
    column: $table.isAutoDebit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get totalInstallments => $composableBuilder(
    column: $table.totalInstallments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BillPlansTableAnnotationComposer get planId {
    final $$BillPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> notificationSchedulesRefs<T extends Object>(
    Expression<T> Function($$NotificationSchedulesTableAnnotationComposer a) f,
  ) {
    final $$NotificationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationSchedules,
          getReferencedColumn: (t) => t.periodId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.notificationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BillPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillPeriodsTable,
          BillPeriod,
          $$BillPeriodsTableFilterComposer,
          $$BillPeriodsTableOrderingComposer,
          $$BillPeriodsTableAnnotationComposer,
          $$BillPeriodsTableCreateCompanionBuilder,
          $$BillPeriodsTableUpdateCompanionBuilder,
          (BillPeriod, $$BillPeriodsTableReferences),
          BillPeriod,
          PrefetchHooks Function({bool planId, bool notificationSchedulesRefs})
        > {
  $$BillPeriodsTableTableManager(_$AppDatabase db, $BillPeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> institution = const Value.absent(),
                Value<String> accountSuffix = const Value.absent(),
                Value<int?> amountInCents = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> reminderDays = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<bool> isAutoDebit = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int?> totalInstallments = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillPeriodsCompanion(
                id: id,
                planId: planId,
                periodKey: periodKey,
                sequence: sequence,
                title: title,
                category: category,
                institution: institution,
                accountSuffix: accountSuffix,
                amountInCents: amountInCents,
                cycle: cycle,
                dueDate: dueDate,
                reminderDays: reminderDays,
                reminderHour: reminderHour,
                isAutoDebit: isAutoDebit,
                note: note,
                totalInstallments: totalInstallments,
                status: status,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required String periodKey,
                required int sequence,
                required String title,
                required String category,
                required String institution,
                required String accountSuffix,
                Value<int?> amountInCents = const Value.absent(),
                required String cycle,
                required String dueDate,
                required String reminderDays,
                required int reminderHour,
                Value<bool> isAutoDebit = const Value.absent(),
                required String note,
                Value<int?> totalInstallments = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BillPeriodsCompanion.insert(
                id: id,
                planId: planId,
                periodKey: periodKey,
                sequence: sequence,
                title: title,
                category: category,
                institution: institution,
                accountSuffix: accountSuffix,
                amountInCents: amountInCents,
                cycle: cycle,
                dueDate: dueDate,
                reminderDays: reminderDays,
                reminderHour: reminderHour,
                isAutoDebit: isAutoDebit,
                note: note,
                totalInstallments: totalInstallments,
                status: status,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BillPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({planId = false, notificationSchedulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (notificationSchedulesRefs) db.notificationSchedules,
                  ],
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
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $$BillPeriodsTableReferences
                                ._planIdTable(db),
                            referencedColumn: $$BillPeriodsTableReferences
                                ._planIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (notificationSchedulesRefs)
                        await $_getPrefetchedData<
                          BillPeriod,
                          $BillPeriodsTable,
                          NotificationSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$BillPeriodsTableReferences
                              ._notificationSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillPeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.periodId == item.id,
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

typedef $$BillPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillPeriodsTable,
      BillPeriod,
      $$BillPeriodsTableFilterComposer,
      $$BillPeriodsTableOrderingComposer,
      $$BillPeriodsTableAnnotationComposer,
      $$BillPeriodsTableCreateCompanionBuilder,
      $$BillPeriodsTableUpdateCompanionBuilder,
      (BillPeriod, $$BillPeriodsTableReferences),
      BillPeriod,
      PrefetchHooks Function({bool planId, bool notificationSchedulesRefs})
    >;
typedef $$ReminderRulesTableCreateCompanionBuilder =
    ReminderRulesCompanion Function({
      required String id,
      required String planId,
      required int daysBeforeDue,
      required int localHour,
      required int localMinute,
      required int sortOrder,
      Value<bool> isEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReminderRulesTableUpdateCompanionBuilder =
    ReminderRulesCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> daysBeforeDue,
      Value<int> localHour,
      Value<int> localMinute,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ReminderRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule> {
  $$ReminderRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BillPlansTable _planIdTable(_$AppDatabase db) =>
      db.billPlans.createAlias('reminder_rules__plan_id__bill_plans__id');

  $$BillPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$BillPlansTableTableManager(
      $_db,
      $_db.billPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $NotificationSchedulesTable,
    List<NotificationSchedule>
  >
  _notificationSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.notificationSchedules,
        aliasName:
            'reminder_rules__id__notification_schedules__reminder_rule_id',
      );

  $$NotificationSchedulesTableProcessedTableManager
  get notificationSchedulesRefs {
    final manager = $$NotificationSchedulesTableTableManager(
      $_db,
      $_db.notificationSchedules,
    ).filter((f) => f.reminderRuleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _notificationSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReminderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
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

  ColumnFilters<int> get daysBeforeDue => $composableBuilder(
    column: $table.daysBeforeDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localHour => $composableBuilder(
    column: $table.localHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
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

  $$BillPlansTableFilterComposer get planId {
    final $$BillPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableFilterComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> notificationSchedulesRefs(
    Expression<bool> Function($$NotificationSchedulesTableFilterComposer f) f,
  ) {
    final $$NotificationSchedulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationSchedules,
          getReferencedColumn: (t) => t.reminderRuleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationSchedulesTableFilterComposer(
                $db: $db,
                $table: $db.notificationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
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

  ColumnOrderings<int> get daysBeforeDue => $composableBuilder(
    column: $table.daysBeforeDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localHour => $composableBuilder(
    column: $table.localHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
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

  $$BillPlansTableOrderingComposer get planId {
    final $$BillPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableOrderingComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get daysBeforeDue => $composableBuilder(
    column: $table.daysBeforeDue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localHour =>
      $composableBuilder(column: $table.localHour, builder: (column) => column);

  GeneratedColumn<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BillPlansTableAnnotationComposer get planId {
    final $$BillPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.billPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.billPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> notificationSchedulesRefs<T extends Object>(
    Expression<T> Function($$NotificationSchedulesTableAnnotationComposer a) f,
  ) {
    final $$NotificationSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.notificationSchedules,
          getReferencedColumn: (t) => t.reminderRuleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NotificationSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.notificationSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReminderRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRulesTable,
          ReminderRule,
          $$ReminderRulesTableFilterComposer,
          $$ReminderRulesTableOrderingComposer,
          $$ReminderRulesTableAnnotationComposer,
          $$ReminderRulesTableCreateCompanionBuilder,
          $$ReminderRulesTableUpdateCompanionBuilder,
          (ReminderRule, $$ReminderRulesTableReferences),
          ReminderRule,
          PrefetchHooks Function({bool planId, bool notificationSchedulesRefs})
        > {
  $$ReminderRulesTableTableManager(_$AppDatabase db, $ReminderRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> daysBeforeDue = const Value.absent(),
                Value<int> localHour = const Value.absent(),
                Value<int> localMinute = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion(
                id: id,
                planId: planId,
                daysBeforeDue: daysBeforeDue,
                localHour: localHour,
                localMinute: localMinute,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int daysBeforeDue,
                required int localHour,
                required int localMinute,
                required int sortOrder,
                Value<bool> isEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion.insert(
                id: id,
                planId: planId,
                daysBeforeDue: daysBeforeDue,
                localHour: localHour,
                localMinute: localMinute,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({planId = false, notificationSchedulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (notificationSchedulesRefs) db.notificationSchedules,
                  ],
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
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $$ReminderRulesTableReferences
                                ._planIdTable(db),
                            referencedColumn: $$ReminderRulesTableReferences
                                ._planIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (notificationSchedulesRefs)
                        await $_getPrefetchedData<
                          ReminderRule,
                          $ReminderRulesTable,
                          NotificationSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$ReminderRulesTableReferences
                              ._notificationSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReminderRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).notificationSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reminderRuleId == item.id,
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

typedef $$ReminderRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRulesTable,
      ReminderRule,
      $$ReminderRulesTableFilterComposer,
      $$ReminderRulesTableOrderingComposer,
      $$ReminderRulesTableAnnotationComposer,
      $$ReminderRulesTableCreateCompanionBuilder,
      $$ReminderRulesTableUpdateCompanionBuilder,
      (ReminderRule, $$ReminderRulesTableReferences),
      ReminderRule,
      PrefetchHooks Function({bool planId, bool notificationSchedulesRefs})
    >;
typedef $$NotificationSchedulesTableCreateCompanionBuilder =
    NotificationSchedulesCompanion Function({
      required String id,
      required String periodId,
      required String reminderRuleId,
      required DateTime fireAt,
      Value<String> status,
      Value<String?> providerId,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> cancelledAt,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NotificationSchedulesTableUpdateCompanionBuilder =
    NotificationSchedulesCompanion Function({
      Value<String> id,
      Value<String> periodId,
      Value<String> reminderRuleId,
      Value<DateTime> fireAt,
      Value<String> status,
      Value<String?> providerId,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> cancelledAt,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$NotificationSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NotificationSchedulesTable,
          NotificationSchedule
        > {
  $$NotificationSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BillPeriodsTable _periodIdTable(_$AppDatabase db) => db.billPeriods
      .createAlias('notification_schedules__period_id__bill_periods__id');

  $$BillPeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<String>('period_id')!;

    final manager = $$BillPeriodsTableTableManager(
      $_db,
      $_db.billPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReminderRulesTable _reminderRuleIdTable(_$AppDatabase db) =>
      db.reminderRules.createAlias(
        'notification_schedules__reminder_rule_id__reminder_rules__id',
      );

  $$ReminderRulesTableProcessedTableManager get reminderRuleId {
    final $_column = $_itemColumn<String>('reminder_rule_id')!;

    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotificationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSchedulesTable> {
  $$NotificationSchedulesTableFilterComposer({
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

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

  $$BillPeriodsTableFilterComposer get periodId {
    final $$BillPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.billPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.billPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReminderRulesTableFilterComposer get reminderRuleId {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderRuleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSchedulesTable> {
  $$NotificationSchedulesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
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

  $$BillPeriodsTableOrderingComposer get periodId {
    final $$BillPeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.billPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.billPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReminderRulesTableOrderingComposer get reminderRuleId {
    final $$ReminderRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderRuleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableOrderingComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSchedulesTable> {
  $$NotificationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BillPeriodsTableAnnotationComposer get periodId {
    final $$BillPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.billPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.billPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReminderRulesTableAnnotationComposer get reminderRuleId {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderRuleId,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotificationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSchedulesTable,
          NotificationSchedule,
          $$NotificationSchedulesTableFilterComposer,
          $$NotificationSchedulesTableOrderingComposer,
          $$NotificationSchedulesTableAnnotationComposer,
          $$NotificationSchedulesTableCreateCompanionBuilder,
          $$NotificationSchedulesTableUpdateCompanionBuilder,
          (NotificationSchedule, $$NotificationSchedulesTableReferences),
          NotificationSchedule,
          PrefetchHooks Function({bool periodId, bool reminderRuleId})
        > {
  $$NotificationSchedulesTableTableManager(
    _$AppDatabase db,
    $NotificationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSchedulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> periodId = const Value.absent(),
                Value<String> reminderRuleId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSchedulesCompanion(
                id: id,
                periodId: periodId,
                reminderRuleId: reminderRuleId,
                fireAt: fireAt,
                status: status,
                providerId: providerId,
                scheduledAt: scheduledAt,
                cancelledAt: cancelledAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String periodId,
                required String reminderRuleId,
                required DateTime fireAt,
                Value<String> status = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotificationSchedulesCompanion.insert(
                id: id,
                periodId: periodId,
                reminderRuleId: reminderRuleId,
                fireAt: fireAt,
                status: status,
                providerId: providerId,
                scheduledAt: scheduledAt,
                cancelledAt: cancelledAt,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotificationSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false, reminderRuleId = false}) {
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
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$NotificationSchedulesTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$NotificationSchedulesTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (reminderRuleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reminderRuleId,
                        referencedTable: $$NotificationSchedulesTableReferences
                            ._reminderRuleIdTable(db),
                        referencedColumn: $$NotificationSchedulesTableReferences
                            ._reminderRuleIdTable(db)
                            .id,
                      ) as T;
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

typedef $$NotificationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSchedulesTable,
      NotificationSchedule,
      $$NotificationSchedulesTableFilterComposer,
      $$NotificationSchedulesTableOrderingComposer,
      $$NotificationSchedulesTableAnnotationComposer,
      $$NotificationSchedulesTableCreateCompanionBuilder,
      $$NotificationSchedulesTableUpdateCompanionBuilder,
      (NotificationSchedule, $$NotificationSchedulesTableReferences),
      NotificationSchedule,
      PrefetchHooks Function({bool periodId, bool reminderRuleId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BillPlansTableTableManager get billPlans =>
      $$BillPlansTableTableManager(_db, _db.billPlans);
  $$BillPeriodsTableTableManager get billPeriods =>
      $$BillPeriodsTableTableManager(_db, _db.billPeriods);
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
  $$NotificationSchedulesTableTableManager get notificationSchedules =>
      $$NotificationSchedulesTableTableManager(_db, _db.notificationSchedules);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
