import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showBudgetAlert(String category, double percentage) async {
    final String message = percentage >= 1.0
        ? 'You have reached 100% of your budget for $category!'
        : 'You have reached 80% of your budget for $category.';

    await _showNotification(category.hashCode, 'Budget Alert', message);
  }

  static Future<void> showDepositSuccess(double amount, String currencyCode) async {
    await _showNotification(
      amount.hashCode,
      'Deposit Successful',
      'You have successfully deposited $currencyCode ${amount.toStringAsFixed(2)} demo funds.',
    );
  }

  static Future<void> showBillPaid(String billName) async {
    await _showNotification(
      billName.hashCode,
      'Bill Paid',
      'Your $billName has been marked as paid.',
    );
  }

  static Future<void> showBillReminder(String billName, DateTime dueDate) async {
    await _showNotification(
      billName.hashCode + 1,
      'Upcoming Bill',
      'Your $billName is due soon (on ${dueDate.day}/${dueDate.month}).',
    );
  }

  static Future<void> showGoalCompleted(String goalTitle) async {
    await _showNotification(
      goalTitle.hashCode,
      'Goal Completed! 🎉',
      'Congratulations! You have reached your savings goal for $goalTitle.',
    );
  }

  static Future<void> showSmsTransactionAlert(String type, double amount, String currency, String category, String merchantOrSender) async {
    final String title = '$type detected';
    final String message = '$currency ${amount.toStringAsFixed(2)}\nProvider/Merchant: $merchantOrSender\nCategory: $category';
    
    await _showNotification(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
    );
  }

  static Future<void> _showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'budget_boss_alerts',
      'BudgetBoss Alerts',
      channelDescription: 'Notifications for BudgetBoss app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
