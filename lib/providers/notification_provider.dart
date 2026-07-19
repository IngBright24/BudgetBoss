import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_preferences.dart';
import '../services/storage_service.dart';

final notificationPrefsProvider = StateNotifierProvider<NotificationPrefsNotifier, NotificationPreferences>((ref) {
  return NotificationPrefsNotifier();
});

class NotificationPrefsNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPrefsNotifier() : super(StorageService.getNotificationPrefs());

  Future<void> toggleApp(bool value) async {
    state = NotificationPreferences(
      appEnabled: value,
      emailEnabled: state.emailEnabled,
      smsEnabled: state.smsEnabled,
    );
    await _save();
  }

  Future<void> toggleEmail(bool value) async {
    state = NotificationPreferences(
      appEnabled: state.appEnabled,
      emailEnabled: value,
      smsEnabled: state.smsEnabled,
    );
    await _save();
  }

  Future<void> toggleSMS(bool value) async {
    state = NotificationPreferences(
      appEnabled: state.appEnabled,
      emailEnabled: state.emailEnabled,
      smsEnabled: value,
    );
    await _save();
  }

  Future<void> _save() async {
    await StorageService.saveNotificationPrefs(state);
  }
}
