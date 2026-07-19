import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/initialization_provider.dart';
import '../../providers/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _finishSplash();
  }

  Future<void> _finishSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    ref.read(initializationProvider.notifier).state = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    final bgDecoration = isDark
        ? const BoxDecoration(color: Color(0xFF020617))
        : const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF020617), Color(0xFF06B6D4)],
            ),
          );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : null,
      body: Container(
        width: double.infinity,
        decoration: bgDecoration,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'BudgetBoss',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Master your money',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
