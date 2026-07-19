import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/security_provider.dart';
import '../../services/local_backup_service.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await ref.read(securityProvider.notifier).isBiometricEnabled();
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Security & Backup', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Authentication', theme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Use Biometrics'),
                  subtitle: const Text('Unlock with Fingerprint or FaceID'),
                  value: _biometricEnabled,
                  onChanged: (val) async {
                    await ref.read(securityProvider.notifier).setBiometricEnabled(val);
                    setState(() => _biometricEnabled = val);
                  },
                  secondary: const Icon(Icons.fingerprint),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Change PIN'),
                  subtitle: const Text('Update your 4-6 digit access code'),
                  leading: const Icon(Icons.password),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to change PIN screen or show dialog
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use "Forgot PIN" on lock screen for now.')));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management', theme),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export Backup'),
                  subtitle: const Text('Save your data locally or share it'),
                  leading: const Icon(Icons.upload_file),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LocalBackupService.exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Restore Backup'),
                  subtitle: const Text('Import a previously exported backup file'),
                  leading: const Icon(Icons.file_download),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LocalBackupService.importBackup(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BudgetBoss is a fully offline app. Your data is stored securely on your device. '
            'We recommend exporting backups regularly to prevent data loss.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
