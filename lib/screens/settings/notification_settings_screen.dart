import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how you want to be notified about budgets, bills, and goals.',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildPreferenceCard(
              context,
              title: 'In-App Notifications',
              subtitle: 'Receive alerts directly within the app',
              icon: Icons.notifications_active_outlined,
              value: prefs.appEnabled,
              onChanged: (val) => ref.read(notificationPrefsProvider.notifier).toggleApp(val),
            ),
            const SizedBox(height: 16),
            _buildPreferenceCard(
              context,
              title: 'Email Alerts',
              subtitle: 'Get spending reports and reminders in your inbox',
              icon: Icons.alternate_email_rounded,
              value: prefs.emailEnabled,
              onChanged: (val) => ref.read(notificationPrefsProvider.notifier).toggleEmail(val),
            ),
            const SizedBox(height: 16),
            _buildPreferenceCard(
              context,
              title: 'SMS Notifications',
              subtitle: 'Receive critical budget warnings via text message',
              icon: Icons.sms_outlined,
              value: prefs.smsEnabled,
              onChanged: (val) => ref.read(notificationPrefsProvider.notifier).toggleSMS(val),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can select multiple channels at once for maximum security.',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF06B6D4), size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF67E8F9),
        activeThumbColor: const Color(0xFF06B6D4),
      ),
    );
  }
}
