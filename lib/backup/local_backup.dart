// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../notifications/notification_coordinator.dart';

const localBackupFormat = 'repayment_assistant.local_backup';
const localBackupVersion = 1;
const _notificationsEnabled = 'notifications_enabled';

class LocalBackupException implements Exception {
  const LocalBackupException(this.message);
  final String message;
  @override
  String toString() => 'LocalBackupException: $message';
}

class LocalBackupRestoreResult {
  const LocalBackupRestoreResult({
    required this.needsNotificationReconcile,
    this.notificationReconcileFailed = false,
  });
  final bool needsNotificationReconcile;
  final bool notificationReconcileFailed;
}

class LocalBackupSummary {
  const LocalBackupSummary({
    required this.version,
    required this.exportedAt,
    required this.planCount,
    required this.periodCount,
    required this.reminderRuleCount,
    required this.notificationsEnabled,
  });
  final int version;
  final DateTime exportedAt;
  final int planCount;
  final int periodCount;
  final int reminderRuleCount;
  final bool notificationsEnabled;
}

/// Explicit application boundary for file/share UI. The service never calls
/// notification reconcile by itself; this controller does so only after the
/// caller has explicitly chosen the restore action.
class LocalBackupController {
  LocalBackupController({required this.service, required this.notifications});
  final LocalBackupService service;
  final NotificationCoordinator notifications;

  Future<LocalBackupRestoreResult> restoreJsonAndReconcile(String json) async {
    final result = await service.restoreJson(json);
    if (result.needsNotificationReconcile) await notifications.reconcile();
    return result;
  }

  Future<LocalBackupRestoreResult> restoreBytesAndReconcile(Uint8List bytes) =>
      restoreJsonAndReconcile(utf8.decode(bytes));
}

class LocalBackupService {
  LocalBackupService(this.database, {DateTime Function()? now})
    : _now = now ?? (() => DateTime.now().toUtc());

  final AppDatabase database;
  final DateTime Function() _now;

  Future<String> exportJson() => database.transaction(() async {
    final plans = await (database.select(
      database.billPlans,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final rules =
        await (database.select(database.reminderRules)..orderBy([
              (t) => OrderingTerm.asc(t.planId),
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.daysBeforeDue),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final periods =
        await (database.select(database.billPeriods)..orderBy([
              (t) => OrderingTerm.asc(t.planId),
              (t) => OrderingTerm.asc(t.sequence),
              (t) => OrderingTerm.asc(t.periodKey),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final setting = await (database.select(
      database.appSettings,
    )..where((t) => t.key.equals(_notificationsEnabled))).getSingleOrNull();
    final document = <String, Object?>{
      'format': localBackupFormat,
      'version': localBackupVersion,
      'exportedAt': _instant(_now()),
      'counts': <String, int>{
        'plans': plans.length,
        'reminderRules': rules.length,
        'periods': periods.length,
      },
      'preferences': <String, Object?>{
        'notificationsEnabled': setting?.value != 'false',
      },
      'plans': plans.map(_planJson).toList(growable: false),
      'reminderRules': rules.map(_ruleJson).toList(growable: false),
      'periods': periods.map(_periodJson).toList(growable: false),
    };
    return jsonEncode(document);
  });

  Future<Uint8List> exportBytes() async =>
      Uint8List.fromList(utf8.encode(await exportJson()));

  Future<LocalBackupSummary> inspectJson(String source) async {
    final parsed = _parse(source);
    return LocalBackupSummary(
      version: localBackupVersion,
      exportedAt: parsed.exportedAt,
      planCount: parsed.plans.length,
      periodCount: parsed.periods.length,
      reminderRuleCount: parsed.rules.length,
      notificationsEnabled: parsed.notificationsEnabled,
    );
  }

  Future<LocalBackupSummary> inspectBytes(Uint8List bytes) =>
      inspectJson(_decodeUtf8(bytes));

  Future<LocalBackupRestoreResult> restoreJson(String source) async {
    final parsed = _parse(source);
    await database.transaction(() async {
      final now = _now().toUtc();
      await database.delete(database.notificationSchedules).go();
      await database.delete(database.billPeriods).go();
      await database.delete(database.reminderRules).go();
      await database.delete(database.billPlans).go();
      for (final row in parsed.plans) {
        await database.into(database.billPlans).insert(_planInsert(row));
      }
      for (final row in parsed.rules) {
        await database.into(database.reminderRules).insert(_ruleInsert(row));
      }
      for (final row in parsed.periods) {
        await database.into(database.billPeriods).insert(_periodInsert(row));
      }
      await database
          .into(database.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: _notificationsEnabled,
              value: parsed.notificationsEnabled ? 'true' : 'false',
              updatedAt: now,
            ),
          );
    });
    return const LocalBackupRestoreResult(needsNotificationReconcile: true);
  }

  Future<LocalBackupRestoreResult> restoreBytes(Uint8List bytes) =>
      restoreJson(_decodeUtf8(bytes));

  String _decodeUtf8(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const LocalBackupException('备份文件不是有效的 UTF-8 文本');
    }
  }

  Map<String, Object?> _planJson(BillPlan r) => {
    'id': r.id,
    'title': r.title,
    'category': r.category,
    'institution': r.institution,
    'accountSuffix': r.accountSuffix,
    'amountInCents': r.amountInCents,
    'cycle': r.cycle,
    'firstDueDate': r.firstDueDate,
    'reminderHour': r.reminderHour,
    'isAutoDebit': r.isAutoDebit,
    'note': r.note,
    'totalInstallments': r.totalInstallments,
    'status': r.status,
    'createdAt': _instant(r.createdAt),
    'updatedAt': _instant(r.updatedAt),
    'archivedAt': r.archivedAt == null ? null : _instant(r.archivedAt!),
  };

  Map<String, Object?> _ruleJson(ReminderRule r) => {
    'id': r.id,
    'planId': r.planId,
    'daysBeforeDue': r.daysBeforeDue,
    'localHour': r.localHour,
    'localMinute': r.localMinute,
    'sortOrder': r.sortOrder,
    'isEnabled': r.isEnabled,
    'createdAt': _instant(r.createdAt),
    'updatedAt': _instant(r.updatedAt),
  };

  Map<String, Object?> _periodJson(BillPeriod r) => {
    'id': r.id,
    'planId': r.planId,
    'periodKey': r.periodKey,
    'sequence': r.sequence,
    'title': r.title,
    'category': r.category,
    'institution': r.institution,
    'accountSuffix': r.accountSuffix,
    'amountInCents': r.amountInCents,
    'cycle': r.cycle,
    'dueDate': r.dueDate,
    'reminderDays': jsonDecode(r.reminderDays),
    'reminderHour': r.reminderHour,
    'isAutoDebit': r.isAutoDebit,
    'note': r.note,
    'totalInstallments': r.totalInstallments,
    'status': r.status,
    'paidAt': r.paidAt == null ? null : _instant(r.paidAt!),
    'createdAt': _instant(r.createdAt),
    'updatedAt': _instant(r.updatedAt),
  };

  BillPlansCompanion _planInsert(Map<String, Object?> r) =>
      BillPlansCompanion.insert(
        id: r['id']! as String,
        title: r['title']! as String,
        category: r['category']! as String,
        institution: r['institution']! as String,
        accountSuffix: r['accountSuffix']! as String,
        amountInCents: Value(r['amountInCents'] as int?),
        cycle: r['cycle']! as String,
        firstDueDate: r['firstDueDate']! as String,
        reminderHour: r['reminderHour']! as int,
        isAutoDebit: Value(r['isAutoDebit']! as bool),
        note: r['note']! as String,
        totalInstallments: Value(r['totalInstallments'] as int?),
        status: Value(r['status']! as String),
        createdAt: r['createdAt']! as DateTime,
        updatedAt: r['updatedAt']! as DateTime,
        archivedAt: Value(r['archivedAt'] as DateTime?),
      );

  ReminderRulesCompanion _ruleInsert(Map<String, Object?> r) =>
      ReminderRulesCompanion.insert(
        id: r['id']! as String,
        planId: r['planId']! as String,
        daysBeforeDue: r['daysBeforeDue']! as int,
        localHour: r['localHour']! as int,
        localMinute: r['localMinute']! as int,
        sortOrder: r['sortOrder']! as int,
        isEnabled: Value(r['isEnabled']! as bool),
        createdAt: r['createdAt']! as DateTime,
        updatedAt: r['updatedAt']! as DateTime,
      );

  BillPeriodsCompanion _periodInsert(Map<String, Object?> r) =>
      BillPeriodsCompanion.insert(
        id: r['id']! as String,
        planId: r['planId']! as String,
        periodKey: r['periodKey']! as String,
        sequence: r['sequence']! as int,
        title: r['title']! as String,
        category: r['category']! as String,
        institution: r['institution']! as String,
        accountSuffix: r['accountSuffix']! as String,
        amountInCents: Value(r['amountInCents'] as int?),
        cycle: r['cycle']! as String,
        dueDate: r['dueDate']! as String,
        reminderDays: jsonEncode(r['reminderDays']),
        reminderHour: r['reminderHour']! as int,
        isAutoDebit: Value(r['isAutoDebit']! as bool),
        note: r['note']! as String,
        totalInstallments: Value(r['totalInstallments'] as int?),
        status: Value(r['status']! as String),
        paidAt: Value(r['paidAt'] as DateTime?),
        createdAt: r['createdAt']! as DateTime,
        updatedAt: r['updatedAt']! as DateTime,
      );

  List<Map<String, Object?>> _list(Object? value, String label) {
    if (value is! List) throw LocalBackupException('$label 必须是数组');
    return value.map((e) => _map(e, label)).toList(growable: false);
  }

  Map<String, Object?> _map(Object? value, String label) {
    if (value is! Map) throw LocalBackupException('$label 必须是对象');
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  _ParsedBackup _parse(String source) {
    late final Map<String, Object?> root;
    try {
      root = _map(jsonDecode(source), '备份根对象');
    } on LocalBackupException {
      rethrow;
    } on Object catch (e) {
      throw LocalBackupException('非法 JSON: $e');
    }
    if (root['format'] != localBackupFormat)
      throw const LocalBackupException('备份格式标识不匹配');
    if (root['version'] != localBackupVersion)
      throw LocalBackupException('不支持的备份版本: ${root['version']}');
    final exportedAt = _instantValue(root['exportedAt'], 'exportedAt');
    final counts = _map(root['counts'], 'counts');
    final plans = _list(root['plans'], 'plans').map(_validatePlan).toList();
    final rules = _list(
      root['reminderRules'],
      'reminderRules',
    ).map(_validateRule).toList();
    final periods = _list(
      root['periods'],
      'periods',
    ).map(_validatePeriod).toList();
    if (counts['plans'] != plans.length ||
        counts['reminderRules'] != rules.length ||
        counts['periods'] != periods.length) {
      throw const LocalBackupException('记录数量与内容不一致');
    }
    final preferences = _map(root['preferences'], 'preferences');
    final enabled = preferences['notificationsEnabled'];
    if (enabled is! bool)
      throw const LocalBackupException('notificationsEnabled 必须是布尔值');
    _validateRelations(plans, rules, periods);
    return _ParsedBackup(exportedAt, plans, rules, periods, enabled);
  }

  Map<String, Object?> _validatePlan(Map<String, Object?> r) {
    _id(r['id'], 'plan.id');
    _requiredText(r, 'title', 'plan');
    if ((r['title'] as String).trim().isEmpty)
      throw const LocalBackupException('计划标题不能为空');
    _enum(r['category'], const {
      'credit_card',
      'mortgage',
      'loan',
      'insurance',
      'subscription',
      'other',
    }, 'plan.category');
    _enum(r['cycle'], const {
      'once',
      'monthly',
      'quarterly',
      'yearly',
    }, 'plan.cycle');
    _enum(r['status'], const {'active', 'paused', 'archived'}, 'plan.status');
    _text(r['institution'], 'plan.institution');
    _text(r['accountSuffix'], 'plan.accountSuffix');
    _money(r['amountInCents'], 'plan.amountInCents');
    _date(r['firstDueDate'], 'plan.firstDueDate');
    _hour(r['reminderHour'], 'plan.reminderHour');
    _bool(r['isAutoDebit'], 'plan.isAutoDebit');
    _text(r['note'], 'plan.note');
    _positiveOrNull(r['totalInstallments'], 'plan.totalInstallments');
    final created = _instantValue(r['createdAt'], 'plan.createdAt');
    _instantValue(r['updatedAt'], 'plan.updatedAt');
    final archived = r['archivedAt'] == null
        ? null
        : _instantValue(r['archivedAt'], 'plan.archivedAt');
    if ((r['status'] == 'archived') != (archived != null))
      throw const LocalBackupException('归档时间与状态不一致');
    if (r['cycle'] == 'once' &&
        r['totalInstallments'] != null &&
        r['totalInstallments'] != 1)
      throw const LocalBackupException('once 计划分期数非法');
    return {
      ...r,
      'createdAt': created,
      'updatedAt': _instantValue(r['updatedAt'], 'plan.updatedAt'),
      'archivedAt': archived,
    };
  }

  Map<String, Object?> _validateRule(Map<String, Object?> r) {
    final plan = _id(r['planId'], 'reminderRule.planId');
    final day = _int(r['daysBeforeDue'], 'reminderRule.daysBeforeDue');
    if (day < 0 || day > 366) throw const LocalBackupException('提醒天数超出范围');
    if (r['id'] != 'reminder-$plan-$day')
      throw const LocalBackupException('提醒规则 canonical identity 非法');
    _id(r['id'], 'reminderRule.id');
    _hour(r['localHour'], 'reminderRule.localHour');
    final minute = _int(r['localMinute'], 'reminderRule.localMinute');
    if (minute < 0 || minute > 59) throw const LocalBackupException('提醒分钟超出范围');
    _nonNegative(r['sortOrder'], 'reminderRule.sortOrder');
    _bool(r['isEnabled'], 'reminderRule.isEnabled');
    return {
      ...r,
      'createdAt': _instantValue(r['createdAt'], 'reminderRule.createdAt'),
      'updatedAt': _instantValue(r['updatedAt'], 'reminderRule.updatedAt'),
    };
  }

  Map<String, Object?> _validatePeriod(Map<String, Object?> r) {
    final plan = _id(r['planId'], 'period.planId');
    final key = _text(r['periodKey'], 'period.periodKey');
    final match = RegExp(r'^period-(\d{6})$').firstMatch(key);
    if (match == null) throw const LocalBackupException('periodKey 非法');
    final sequence = _positive(r['sequence'], 'period.sequence');
    if (int.parse(match.group(1)!) != sequence)
      throw const LocalBackupException('periodKey 与 sequence 不一致');
    _id(r['id'], 'period.id');
    if (r['id'] != '$plan::$key')
      throw const LocalBackupException('账期 canonical identity 非法');
    _requiredText(r, 'title', 'period');
    if ((r['title'] as String).trim().isEmpty)
      throw const LocalBackupException('账期标题不能为空');
    _enum(r['category'], const {
      'credit_card',
      'mortgage',
      'loan',
      'insurance',
      'subscription',
      'other',
    }, 'period.category');
    _enum(r['cycle'], const {
      'once',
      'monthly',
      'quarterly',
      'yearly',
    }, 'period.cycle');
    _text(r['institution'], 'period.institution');
    _text(r['accountSuffix'], 'period.accountSuffix');
    if (r['cycle'] == 'once' && sequence != 1)
      throw const LocalBackupException('once 账期 sequence 必须为 1');
    _money(r['amountInCents'], 'period.amountInCents');
    _date(r['dueDate'], 'period.dueDate');
    _hour(r['reminderHour'], 'period.reminderHour');
    final days = r['reminderDays'];
    if (days is! List ||
        days.any((v) => v is! int || v < 0 || v > 366) ||
        days.toSet().length != days.length)
      throw const LocalBackupException('账期提醒天数非法');
    _bool(r['isAutoDebit'], 'period.isAutoDebit');
    _text(r['note'], 'period.note');
    _positiveOrNull(r['totalInstallments'], 'period.totalInstallments');
    final status = _enum(r['status'], const {
      'pending',
      'paid',
      'skipped',
    }, 'period.status');
    final paid = r['paidAt'] == null
        ? null
        : _instantValue(r['paidAt'], 'period.paidAt');
    if ((status == 'paid') != (paid != null))
      throw const LocalBackupException('paidAt 与状态不一致');
    return {
      ...r,
      'createdAt': _instantValue(r['createdAt'], 'period.createdAt'),
      'updatedAt': _instantValue(r['updatedAt'], 'period.updatedAt'),
      'paidAt': paid,
    };
  }

  void _validateRelations(
    List<Map<String, Object?>> plans,
    List<Map<String, Object?>> rules,
    List<Map<String, Object?>> periods,
  ) {
    final planIds = <String>{};
    for (final p in plans) {
      if (!planIds.add(p['id']! as String))
        throw const LocalBackupException('计划 ID 重复');
    }
    final planLimits = {
      for (final p in plans) p['id']! as String: p['totalInstallments'] as int?,
    };
    final keys = <String>{};
    for (final r in rules) {
      if (!planIds.contains(r['planId']) ||
          !keys.add('${r['planId']}:${r['daysBeforeDue']}'))
        throw const LocalBackupException('提醒规则外键或唯一键冲突');
    }
    final periodKeys = <String>{};
    for (final p in periods) {
      if (!planIds.contains(p['planId']) ||
          !periodKeys.add('${p['planId']}:${p['periodKey']}'))
        throw const LocalBackupException('账期外键或唯一键冲突');
      if (planLimits[p['planId']] != null &&
          p['sequence']! as int > planLimits[p['planId']]!)
        throw const LocalBackupException('账期序号超过计划分期总数');
    }
    final ruleIds = <String>{for (final r in rules) r['id']! as String};
    if (ruleIds.length != rules.length)
      throw const LocalBackupException('提醒规则 ID 重复');
    final periodIds = <String>{for (final p in periods) p['id']! as String};
    if (periodIds.length != periods.length)
      throw const LocalBackupException('账期 ID 重复');
  }

  String _id(Object? v, String label) {
    final s = _text(v, label);
    if (s.trim().isEmpty || s != s.trim() || s.contains(RegExp(r'\s')))
      throw LocalBackupException('$label 非法');
    return s;
  }

  String _requiredText(Map<String, Object?> r, String key, String label) =>
      _text(r[key], '$label.$key');
  String _text(Object? v, String label) =>
      v is String ? v : LocalBackupException('$label 必须是字符串').throwIt();
  int _int(Object? v, String label) =>
      v is int ? v : LocalBackupException('$label 必须是整数').throwIt();
  int _positive(Object? v, String label) {
    final i = _int(v, label);
    if (i <= 0) throw LocalBackupException('$label 必须大于 0');
    return i;
  }

  int _nonNegative(Object? v, String label) {
    final i = _int(v, label);
    if (i < 0) throw LocalBackupException('$label 不能为负数');
    return i;
  }

  int? _positiveOrNull(Object? v, String label) =>
      v == null ? null : _positive(v, label);
  int? _money(Object? v, String label) {
    if (v == null) return null;
    final i = _int(v, label);
    if (i < 0) throw LocalBackupException('$label 不能为负数');
    return i;
  }

  int _hour(Object? v, String label) {
    final i = _int(v, label);
    if (i < 0 || i > 23) throw LocalBackupException('$label 超出范围');
    return i;
  }

  bool _bool(Object? v, String label) =>
      v is bool ? v : LocalBackupException('$label 必须是布尔值').throwIt();
  String _enum(Object? v, Set<String> values, String label) {
    final s = _text(v, label);
    if (!values.contains(s)) throw LocalBackupException('$label 枚举值非法');
    return s;
  }

  String _date(Object? v, String label) {
    final s = _text(v, label);
    final d = DateTime.tryParse(s);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s) ||
        d == null ||
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}' !=
            s)
      throw LocalBackupException('$label 日期非法');
    return s;
  }

  DateTime _instantValue(Object? v, String label) {
    final s = _text(v, label);
    final d = DateTime.tryParse(s);
    if (d == null || !d.isUtc || !s.endsWith('Z'))
      throw LocalBackupException('$label 必须是 ISO-8601 UTC');
    return d.toUtc();
  }

  String _instant(DateTime d) => d.toUtc().toIso8601String();
}

extension on LocalBackupException {
  Never throwIt() => throw this;
}

class _ParsedBackup {
  _ParsedBackup(
    this.exportedAt,
    this.plans,
    this.rules,
    this.periods,
    this.notificationsEnabled,
  );

  final DateTime exportedAt;
  final List<Map<String, Object?>> plans;
  final List<Map<String, Object?>> rules;
  final List<Map<String, Object?>> periods;
  final bool notificationsEnabled;
}
