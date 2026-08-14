import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/backup/backup_controller.dart';
import 'package:repayment_assistant/backup/backup_file_gateway.dart';
import 'package:repayment_assistant/backup/local_backup.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/state/bill_store.dart';

void main() {
  late AppDatabase database;
  late LocalBillingRepository repository;
  late BillStore store;
  late FakeBackupFiles files;
  late BackupController controller;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = LocalBillingRepository(database);
    store = BillStore(repository);
    files = FakeBackupFiles();
    controller = BackupController(
      service: LocalBackupService(database, now: () => DateTime.utc(2026, 8, 14, 9, 10, 11)),
      files: files,
      store: store,
      now: () => DateTime(2026, 8, 14, 9, 10, 11),
    );
  });

  tearDown(() async {
    store.dispose();
    await database.close();
  });

  test('export uses a stable filename and UTF-8 JSON without platform calls', () async {
    await controller.exportBackup();
    expect(files.sharedName, 'DueDay-backup-20260814-091011.json');
    expect(utf8.decode(files.sharedBytes!), contains('repayment_assistant.local_backup'));
  });

  test('cancelled picker leaves data unchanged and inspect reports summary', () async {
    await repository.savePlan(_plan());
    await store.load();
    files.picked = null;
    expect(await controller.pickAndInspect(), isNull);
    expect(store.plans.single.id, 'existing');
  });
}

class FakeBackupFiles implements BackupFileGateway {
  String? sharedName;
  Uint8List? sharedBytes;
  PickedBackupFile? picked;

  @override
  Future<void> shareJson({required String fileName, required Uint8List bytes}) async {
    sharedName = fileName;
    sharedBytes = bytes;
  }

  @override
  Future<PickedBackupFile?> pickJson() async => picked;
}

BillingPlan _plan() => BillingPlan(
  id: 'existing',
  title: '现有账单',
  category: BillCategory.other,
  amountInCents: null,
  cycle: BillingCycle.once,
  firstDueDate: DateTime(2026, 8, 20),
  createdAt: DateTime.utc(2026, 8, 1),
);
