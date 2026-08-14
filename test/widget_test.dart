import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/app.dart';
import 'package:repayment_assistant/data/local/app_database.dart';

void main() {
  final now = DateTime(2026, 8, 13, 15, 30);
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('opens in a useful empty state without demo data or login', (
    tester,
  ) async {
    await tester.pumpWidget(
      RepaymentAssistantApp(database: database, now: () => now),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Paul'), findsOneWidget);
    expect(find.text('登录'), findsNothing);
    expect(find.text('先记下第一笔固定支付'), findsOneWidget);
    expect(find.textContaining('车位贷款'), findsNothing);
  });

  testWidgets('navigates to bills and opens the create form', (tester) async {
    await tester.pumpWidget(
      RepaymentAssistantApp(database: database, now: () => now),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('账单计划'), findsOneWidget);

    await tester.tap(find.byTooltip('新增账单'));
    await tester.pumpAndSettle();
    expect(find.text('新增账单'), findsOneWidget);
    expect(find.text('账单类型'), findsOneWidget);
    expect(find.text('保存账单'), findsOneWidget);
  });

  testWidgets('the app does not close an injected database on dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      RepaymentAssistantApp(database: database, now: () => now),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(await database.select(database.billPlans).get(), isEmpty);
    expect(await database.select(database.appSettings).get(), isNotEmpty);
  });
}
