import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class BillPlans extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  TextColumn get institution => text()();

  TextColumn get accountSuffix => text().named('account_suffix')();

  IntColumn get amountInCents =>
      integer().named('amount_in_cents').nullable()();

  TextColumn get cycle => text()();

  TextColumn get firstDueDate => text().named('first_due_date')();

  IntColumn get reminderHour => integer().named('reminder_hour')();

  BoolColumn get isAutoDebit =>
      boolean().named('is_auto_debit').withDefault(const Constant(false))();

  TextColumn get note => text()();

  IntColumn get totalInstallments =>
      integer().named('total_installments').nullable()();

  TextColumn get status => text().withDefault(const Constant('active'))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(title)) > 0)',
    "CHECK (category IN ('credit_card', 'mortgage', 'loan', 'insurance', 'subscription', 'other'))",
    "CHECK (cycle IN ('once', 'monthly', 'quarterly', 'yearly'))",
    "CHECK (first_due_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND date(first_due_date) = first_due_date)",
    'CHECK (reminder_hour BETWEEN 0 AND 23)',
    'CHECK (amount_in_cents IS NULL OR amount_in_cents >= 0)',
    'CHECK (total_installments IS NULL OR total_installments > 0)',
    "CHECK (cycle <> 'once' OR total_installments IS NULL OR total_installments = 1)",
    "CHECK (status IN ('active', 'paused', 'archived'))",
    "CHECK ((status = 'archived' AND archived_at IS NOT NULL) OR (status <> 'archived' AND archived_at IS NULL))",
  ];

  List<Index> get indexes => [
    Index(
      'bill_plans_status_due_idx',
      'CREATE INDEX bill_plans_status_due_idx ON bill_plans (status, first_due_date)',
    ),
  ];
}

class BillPeriods extends Table {
  TextColumn get id => text()();

  TextColumn get planId => text()
      .named('plan_id')
      .references(
        BillPlans,
        #id,
        onDelete: KeyAction.restrict,
        onUpdate: KeyAction.cascade,
      )();

  TextColumn get periodKey => text().named('period_key')();

  IntColumn get sequence => integer()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  TextColumn get institution => text()();

  TextColumn get accountSuffix => text().named('account_suffix')();

  IntColumn get amountInCents =>
      integer().named('amount_in_cents').nullable()();

  TextColumn get cycle => text()();

  TextColumn get dueDate => text().named('due_date')();

  TextColumn get reminderDays => text().named('reminder_days')();

  IntColumn get reminderHour => integer().named('reminder_hour')();

  BoolColumn get isAutoDebit =>
      boolean().named('is_auto_debit').withDefault(const Constant(false))();

  TextColumn get note => text()();

  IntColumn get totalInstallments =>
      integer().named('total_installments').nullable()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get paidAt => dateTime().named('paid_at').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {planId, periodKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(plan_id)) > 0)',
    "CHECK (period_key GLOB 'period-[0-9][0-9][0-9][0-9][0-9][0-9]')",
    'CHECK (sequence > 0)',
    "CHECK (category IN ('credit_card', 'mortgage', 'loan', 'insurance', 'subscription', 'other'))",
    "CHECK (cycle IN ('once', 'monthly', 'quarterly', 'yearly'))",
    "CHECK (due_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND date(due_date) = due_date)",
    'CHECK (json_valid(reminder_days) = 1)',
    "CHECK (json_type(reminder_days) = 'array')",
    'CHECK (reminder_hour BETWEEN 0 AND 23)',
    'CHECK (amount_in_cents IS NULL OR amount_in_cents >= 0)',
    'CHECK (total_installments IS NULL OR total_installments > 0)',
    "CHECK (cycle <> 'once' OR total_installments IS NULL OR total_installments = 1)",
    "CHECK (status IN ('pending', 'paid', 'skipped'))",
    "CHECK ((status = 'paid' AND paid_at IS NOT NULL) OR (status <> 'paid' AND paid_at IS NULL))",
  ];

  List<Index> get indexes => [
    Index(
      'bill_periods_plan_due_idx',
      'CREATE INDEX bill_periods_plan_due_idx ON bill_periods (plan_id, due_date)',
    ),
    Index(
      'bill_periods_status_due_idx',
      'CREATE INDEX bill_periods_status_due_idx ON bill_periods (status, due_date)',
    ),
  ];
}

class ReminderRules extends Table {
  TextColumn get id => text()();

  TextColumn get planId => text()
      .named('plan_id')
      .references(
        BillPlans,
        #id,
        onDelete: KeyAction.restrict,
        onUpdate: KeyAction.cascade,
      )();

  IntColumn get daysBeforeDue => integer().named('days_before_due')();

  IntColumn get localHour => integer().named('local_hour')();

  IntColumn get localMinute => integer().named('local_minute')();

  IntColumn get sortOrder => integer().named('sort_order')();

  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {planId, daysBeforeDue},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (days_before_due BETWEEN 0 AND 366)',
    'CHECK (local_hour BETWEEN 0 AND 23)',
    'CHECK (local_minute BETWEEN 0 AND 59)',
    'CHECK (sort_order >= 0)',
  ];

  List<Index> get indexes => [
    Index(
      'reminder_rules_plan_enabled_idx',
      'CREATE INDEX reminder_rules_plan_enabled_idx ON reminder_rules (plan_id, is_enabled, sort_order)',
    ),
  ];
}

class NotificationSchedules extends Table {
  TextColumn get id => text()();

  TextColumn get periodId => text()
      .named('period_id')
      .references(
        BillPeriods,
        #id,
        onDelete: KeyAction.restrict,
        onUpdate: KeyAction.cascade,
      )();

  TextColumn get reminderRuleId => text()
      .named('reminder_rule_id')
      .references(
        ReminderRules,
        #id,
        onDelete: KeyAction.restrict,
        onUpdate: KeyAction.cascade,
      )();

  DateTimeColumn get fireAt => dateTime().named('fire_at')();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get providerId => text().named('provider_id').nullable()();

  DateTimeColumn get scheduledAt =>
      dateTime().named('scheduled_at').nullable()();

  DateTimeColumn get cancelledAt =>
      dateTime().named('cancelled_at').nullable()();

  TextColumn get lastError => text().named('last_error').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {periodId, reminderRuleId},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('pending', 'scheduled', 'cancelled', 'failed', 'expired'))",
    "CHECK ((status = 'scheduled' AND scheduled_at IS NOT NULL) OR status <> 'scheduled')",
    "CHECK ((status = 'cancelled' AND cancelled_at IS NOT NULL) OR status <> 'cancelled')",
  ];

  List<Index> get indexes => [
    Index(
      'notification_schedules_status_fire_idx',
      'CREATE INDEX notification_schedules_status_fire_idx ON notification_schedules (status, fire_at)',
    ),
  ];
}

class AppSettings extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    BillPlans,
    BillPeriods,
    ReminderRules,
    NotificationSchedules,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  AppDatabase.defaults() : super(driftDatabase(name: 'dueday'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Version 1 is the initial schema. Future versions must add explicit,
      // ordered migrations here and keep existing bill-period snapshots intact.
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await into(appSettings).insert(
          AppSettingsCompanion.insert(
            key: 'notifications_enabled',
            value: 'true',
            updatedAt: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    },
  );
}
