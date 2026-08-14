import '../domain/bill_period.dart';

class NotificationMessage {
  const NotificationMessage({required this.title, required this.body});

  final String title;
  final String body;
}

class NotificationCopy {
  const NotificationCopy._();

  static NotificationMessage forPeriod(BillPeriod period) {
    final amount = period.amountInCents == null
        ? ''
        : '，金额 ¥${_formatAmount(period.amountInCents!)}';
    return NotificationMessage(
      title: '账单提醒',
      body:
          '${period.title}将在${period.dueDate.month}月${period.dueDate.day}日到期$amount',
    );
  }

  static String _formatAmount(int cents) {
    final yuan = cents ~/ 100;
    final remainder = cents % 100;
    if (remainder == 0) return yuan.toString();
    return '$yuan.${remainder.toString().padLeft(2, '0')}';
  }
}
