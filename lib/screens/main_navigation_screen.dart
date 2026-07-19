import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/datasource/sms_listener.dart';
import '../data/repository/sms_repository.dart';
import '../presentation/providers/sms_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'budgets/budgets_screen.dart';
import 'goals/goals_screen.dart';
import 'bills/bills_screen.dart';
import 'reports/reports_screen.dart';
import '../widgets/top_bar_actions.dart';
import '../services/storage_service.dart';
import 'settings/security_settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final SmsListener _smsListener;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetsScreen(),
    const BillsScreen(),
    const GoalsScreen(),
    const ReportsScreen(),
  ];

  final List<String> _titles = [
    'BudgetBoss',
    'Activity History',
    'Budgeting',
    'Monthly Bills',
    'Savings Goals',
    'Financial Reports',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSmsModule();
    _showLockSetupPromptIfNeeded();
  }

  Future<void> _showLockSetupPromptIfNeeded() async {
    // Only show once, and only if the user has never set up a lock
    if (StorageService.hasShownLockSetupPrompt() || StorageService.isPinLockEnabled()) return;
    await StorageService.setHasShownLockSetupPrompt(true);
    // Wait for the first frame so the screen is fully rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.security_outlined, color: Color(0xFF06B6D4)),
              const SizedBox(width: 10),
              const Text('Secure Your App', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Set up a PIN, fingerprint, or Face ID so you can quickly reopen the app without logging in again every time.\n\nYou can do this in Settings → Security.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                );
              },
              child: const Text('Set Up Now'),
            ),
          ],
        ),
      );
    });
  }

  void _initSmsModule() {
    // Request permissions and sync existing inbox on first launch
    Future.microtask(() async {
      await ref.read(smsProvider.notifier).requestPermissions();
      if (!mounted) return;
      // Refresh the main transaction feed and wallet after inbox scan
      await ref.read(transactionProvider.notifier).loadTransactions();
      final allTxs = ref.read(transactionProvider);
      await ref.read(walletProvider.notifier).recalculateFrom(allTxs);
    });

    // Start real-time listener for new incoming SMS
    _smsListener = SmsListener(
      SmsRepository(),
      onNewTransaction: () async {
        if (!mounted) return;
        // Refresh SMS list, transaction feed, and wallet immediately
        await ref.read(smsProvider.notifier).loadTransactions();
        await ref.read(transactionProvider.notifier).loadTransactions();
        final allTxs = ref.read(transactionProvider);
        await ref.read(walletProvider.notifier).recalculateFrom(allTxs);
      },
    );
    _smsListener.startListening();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: const [
          TopBarActions(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                _buildNavItem(1, Icons.account_balance_wallet_rounded, 'Activity'),
                _buildNavItem(2, Icons.pie_chart_rounded, 'Budget'),
                _buildNavItem(3, Icons.receipt_long_rounded, 'Bills'),
                _buildNavItem(4, Icons.savings_rounded, 'Goals'),
                _buildNavItem(5, Icons.bar_chart_rounded, 'Reports'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Vivid, saturated active color
    final activeColor = theme.colorScheme.primary;
    // Solid black/white for inactive tabs — opacity handles the dimming
    final inactiveColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        // Selected tab is fully opaque; others are noticeably dimmed
        opacity: isSelected ? 1.0 : 0.45,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            // Selected tab gets a strong tinted pill background
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.22 : 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            // Subtle border on selected tab for extra pop
            border: isSelected
                ? Border.all(
                    color: activeColor.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.15 : 1.0,
                child: Icon(
                  icon,
                  // Active icon uses the full vivid primary; inactive stays neutral
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: GoogleFonts.poppins(
                  fontSize: isSelected ? 10 : 9.5,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
