import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/app.dart';
import 'package:repayment_assistant/features/bills/bill_form_screen.dart';
import 'package:repayment_assistant/features/shell/app_shell.dart';

void main() {
  testWidgets('capture primary iPhone screens', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RepaymentAssistantApp());
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('goldens/home.png'),
    );

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('goldens/bills.png'),
    );

    await tester.tap(find.byTooltip('新增账单'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BillFormScreen),
      matchesGoldenFile('goldens/bill-form.png'),
    );
  });
}
