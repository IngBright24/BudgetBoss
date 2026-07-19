import 'package:hive/hive.dart';

part 'notification_preferences.g.dart';

@HiveType(typeId: 7)
class NotificationPreferences extends HiveObject {
  @HiveField(0)
  bool appEnabled;

  @HiveField(1)
  bool emailEnabled;

  @HiveField(2)
  bool smsEnabled;

  NotificationPreferences({
    this.appEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
  });
}
