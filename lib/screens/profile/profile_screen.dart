import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/user_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/storage_service.dart';
import '../../services/export_service.dart';
import '../../models/user.dart';

import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/security_settings_screen.dart';
import '../../presentation/pages/sms_test_page.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmailSupport() async {
    final uri = Uri.parse('mailto:support@budgetboss.app?subject=Support%20Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('No user data found. Please sign in.')),
      );
    }

    final transactions = ref.watch(transactionProvider);
    final currency = ref.watch(currencyProvider);
        final profilePicPath = ref.watch(profilePictureProvider);

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // ── Responsive scaling ──────────────────────────────────────────
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmall = screenWidth < 360;
        final hPad = screenWidth * 0.05;          // 5 % horizontal padding
        final avatarSize = (screenWidth * 0.20).clamp(64.0, 100.0);
        final nameFontSize = (screenWidth * 0.055).clamp(16.0, 24.0);
        final subFontSize = (screenWidth * 0.033).clamp(11.0, 14.0);
        final cardRadius = (screenWidth * 0.05).clamp(12.0, 22.0);
        final shortcutIconPad = (screenWidth * 0.04).clamp(10.0, 18.0);
        final shortcutIconSize = (screenWidth * 0.06).clamp(20.0, 28.0);
        final sectionVGap = (screenHeight * 0.025).clamp(12.0, 28.0);
        // ────────────────────────────────────────────────────────────────

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold,
                fontSize: (screenWidth * 0.048).clamp(15.0, 20.0))),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sectionVGap * 0.6),
        child: Column(
          children: [
            // ── User Info Header ───────────────────────────────────
            Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2),
                  ),
                  child: ClipOval(
                    child: profilePicPath != null &&
                            File(profilePicPath).existsSync()
                        ? Image.file(File(profilePicPath),
                            fit: BoxFit.cover,
                            width: avatarSize,
                            height: avatarSize)
                        : Icon(Icons.person,
                            size: avatarSize * 0.5,
                            color: theme.colorScheme.primary),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: subFontSize),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: screenHeight * 0.006),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.025,
                            vertical: screenHeight * 0.004),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pro Member',
                          style: TextStyle(
                              fontSize: subFontSize * 0.85,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF06B6D4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: sectionVGap),

            // ── Quick Shortcuts ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickShortcut(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  iconPad: shortcutIconPad,
                  iconSize: shortcutIconSize,
                  labelFontSize: subFontSize,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                _QuickShortcut(
                  icon: Icons.security_outlined,
                  label: 'Security',
                  iconPad: shortcutIconPad,
                  iconSize: shortcutIconSize,
                  labelFontSize: subFontSize,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const SecuritySettingsScreen())),
                ),
                _QuickShortcut(
                  icon: Icons.edit_note,
                  label: 'Edit Info',
                  iconPad: shortcutIconPad,
                  iconSize: shortcutIconSize,
                  labelFontSize: subFontSize,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen())),
                ),
              ],
            ),

            SizedBox(height: sectionVGap),

            // ── App Actions ────────────────────────────────────────
            _buildActionCard(
              context,
              title: 'App Actions',
              cardRadius: cardRadius,
              subFontSize: subFontSize,
              items: [
                _ActionItem(
                  icon: Icons.file_download_outlined,
                  title: 'Export History (CSV)',
                  subtitle: 'Download spreadsheet report',
                  color: const Color(0xFF10B981),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preparing CSV report...')),
                    );
                    await ExportService.exportTransactionsToCSV(
                        transactions, currency.code);
                  },
                ),
                _ActionItem(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Export History (PDF)',
                  subtitle: 'Download printable report',
                  color: const Color(0xFFEF4444),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preparing PDF report...')),
                    );
                    await ExportService.exportTransactionsToPDF(
                        transactions, currency.code);
                  },
                ),
                _ActionItem(
                  icon: Icons.developer_mode,
                  title: 'Developer: SMS Parser Test',
                  subtitle: 'Test financial SMS offline parser',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SmsTestPage())),
                ),
              ],
            ),

            SizedBox(height: sectionVGap),

            // ── Support & Community ────────────────────────────────
            _buildActionCard(
              context,
              title: 'Support & Community',
              cardRadius: cardRadius,
              subFontSize: subFontSize,
              items: [
                _ActionItem(
                  icon: Icons.help_outline,
                  title: 'Help Center & FAQ',
                  subtitle: 'Find answers to common questions',
                  onTap: () => _launchUrl('https://budgetboss.app/faq'),
                ),
                _ActionItem(
                  icon: Icons.mail_outline,
                  title: 'Contact Support',
                  subtitle: 'Email us if you need help',
                  onTap: _sendEmailSupport,
                ),
                _ActionItem(
                  icon: Icons.share_outlined,
                  title: 'Share BudgetBoss',
                  subtitle: 'Invite friends to use the app',
                  onTap: () => Share.share(
                      'Check out BudgetBoss, the best app to track your finances!'),
                ),
                _ActionItem(
                  icon: Icons.star_border,
                  title: 'Rate Us',
                  subtitle: 'Leave a 5-star review',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _launchUrl('https://budgetboss.app/rate'),
                ),
              ],
            ),

            SizedBox(height: sectionVGap),

            // ── Legal ──────────────────────────────────────────────
            _buildActionCard(
              context,
              title: 'Legal',
              cardRadius: cardRadius,
              subFontSize: subFontSize,
              items: [
                _ActionItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => _launchUrl('https://budgetboss.app/privacy'),
                ),
                _ActionItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Our rules and guidelines',
                  onTap: () => _launchUrl('https://budgetboss.app/terms'),
                ),
              ],
            ),

            SizedBox(height: sectionVGap * 1.5),
            Text(
              'BudgetBoss v1.0.0\nJoined ${user.registrationDate.day}/${user.registrationDate.month}/${user.registrationDate.year}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: subFontSize * 0.9),
            ),
            SizedBox(height: sectionVGap * 1.5),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required List<_ActionItem> items,
    required double cardRadius,
    required double subFontSize,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.02, bottom: screenWidth * 0.025),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: (screenWidth * 0.028).clamp(9.0, 12.0),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF06B6D4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.01),
                    leading: Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: (item.color ?? theme.colorScheme.primary)
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.025),
                      ),
                      child: Icon(item.icon,
                          color: item.color ?? theme.colorScheme.primary,
                          size: (screenWidth * 0.05).clamp(16.0, 22.0)),
                    ),
                    title: Text(item.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (screenWidth * 0.036).clamp(12.0, 15.0))),
                    subtitle: Text(item.subtitle,
                        style: TextStyle(
                            fontSize: subFontSize * 0.88,
                            color: Colors.grey.shade500)),
                    trailing: Icon(Icons.chevron_right,
                        size: (screenWidth * 0.045).clamp(14.0, 20.0),
                        color: Colors.grey),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        indent: screenWidth * 0.16,
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconPad;
  final double iconSize;
  final double labelFontSize;
  final VoidCallback onTap;

  const _QuickShortcut({
    required this.icon,
    required this.label,
    required this.iconPad,
    required this.iconSize,
    required this.labelFontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(iconPad),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF06B6D4), size: iconSize),
          ),
          SizedBox(height: iconPad * 0.4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: labelFontSize * 0.88,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  _ActionItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.color});
}
