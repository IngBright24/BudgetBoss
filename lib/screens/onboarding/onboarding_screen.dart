import 'package:flutter/material.dart';
import '../../services/sms_service.dart';
import '../../services/storage_service.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 100, color: Color(0xFF06B6D4)),
            const SizedBox(height: 32),
            const Text(
              'Welcome to BudgetBoss',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'To automatically track your expenses, BudgetBoss needs permission to read incoming Mobile Money SMS notifications. Tracking begins from the moment you grant permission.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                final granted = await SMSService.requestPermissions();
                if (granted && context.mounted) {
                  await StorageService.setOnboardingCompleted();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SMS permission is required to use BudgetBoss.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Grant Permission & Start'),
            ),
          ],
        ),
      ),
    );
  }
}
