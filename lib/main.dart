import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/registration_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/initialization_provider.dart';
import 'screens/security/pin_screen.dart';
import 'providers/user_provider.dart';
import 'providers/security_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage (Hive for settings + SQLite for financial data)
  await StorageService.init();

  // Initialize Notifications
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: BudgetBossApp(),
    ),
  );
}

class BudgetBossApp extends ConsumerStatefulWidget {
  const BudgetBossApp({super.key});

  @override
  ConsumerState<BudgetBossApp> createState() => _BudgetBossAppState();
}

class _BudgetBossAppState extends ConsumerState<BudgetBossApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Lock the app when it goes to background
      ref.read(securityProvider.notifier).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isInitialized = ref.watch(initializationProvider);
    final isUnlocked = ref.watch(securityProvider);
    final localUser = ref.watch(userProvider);

    return MaterialApp(
      title: 'BudgetBoss',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF06B6D4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF06B6D4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardTheme: const CardThemeData(
          color: Color(0xFF111827),
        ),
      ),
      builder: (context, child) {
        if (!isInitialized) {
          return const SplashScreen();
        }
        
        // App-level overlay: if the app is locked and we are initialized, show PinScreen over everything
        if (!isUnlocked) {
          return const PinScreen();
        }
        
        return child!;
      },
      home: _resolveHome(localUser),
    );
  }

  Widget _resolveHome(localUser) {
    if (localUser == null) {
      return const RegistrationScreen();
    }
    return const MainNavigationScreen();
  }
}
