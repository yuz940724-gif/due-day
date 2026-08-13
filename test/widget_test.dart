import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/app.dart';

void main() {
  testWidgets('opens directly on the home screen without login', (
    tester,
  ) async {
    await tester.pumpWidget(const RepaymentAssistantApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.textContaining('Paul'), findsOneWidget);
    expect(find.text('登录'), findsNothing);
    expect(find.textContaining('车位贷款'), findsWidgets);
    expect(find.text('需要处理'), findsOneWidget);
  });

  testWidgets('navigates to bills and opens the create form', (tester) async {
    await tester.pumpWidget(const RepaymentAssistantApp());
    await tester.pump(const Duration(milliseconds: 200));
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
}
