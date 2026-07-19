import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import '../../providers/currency_provider.dart';
import '../../providers/security_provider.dart';

// Helper class for RadioGroup
class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;
  
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, Currency current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Currency.values.map((c) => ListTile(
            title: Text('${c.code} (${c.symbol})'),
            leading: Radio<Currency>(
              value: c,
              groupValue: current,
              onChanged: (val) {
                if (val != null) {
                  ref.read(currencyProvider.notifier).setCurrency(val);
                  Navigator.pop(context);
                }
              },
            ),
            onTap: () {
              ref.read(currencyProvider.notifier).setCurrency(c);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all transactions, budgets, and goals. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              ref.read(walletProvider.notifier).reset();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared.')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildSettingsSection(
            'App Preferences',
            [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: themeMode == ThemeMode.dark,
                onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notification Preferences'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: const Text('Currency'),
                subtitle: Text('${currency.code} (${currency.symbol})'),
                onTap: () => _showCurrencyPicker(context, ref, currency),
              ),
            ],
          ),
          _buildSettingsSection(
            'Security & Backup',
            [
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('Security & Data Backup'),
                subtitle: const Text('Manage PIN, Biometrics & Backups'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                ),
              ),
            ],
          ),
          _buildSettingsSection(
            'System',
            [
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.blue),
                title: const Text('Lock App'),
                subtitle: const Text('Lock BudgetBoss immediately'),
                onTap: () {
                  ref.read(securityProvider.notifier).lockApp();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: Color(0xFFEF4444)),
                title: const Text('Clear All Data', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () => _confirmClearData(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'BudgetBoss v1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF06B6D4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }
}
