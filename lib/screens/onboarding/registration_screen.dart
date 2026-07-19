import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../../providers/user_provider.dart';
import '../../providers/security_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _useBiometrics = false;
  
  // Recovery code
  String _recoveryCode = '';
  bool _hasSavedCode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _generateRecoveryCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String generateSegment() => List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    _recoveryCode = '${generateSegment()}-${generateSegment()}-${generateSegment()}';
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _generateRecoveryCode();
      setState(() {});
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeRegistration() async {
    if (!_hasSavedCode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please confirm you have saved the recovery code.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Setup Security (PIN and Recovery Code)
      await ref.read(securityProvider.notifier).setupSecurity(_pinController.text, _recoveryCode);
      
      // 2. Setup Biometrics preference
      await ref.read(securityProvider.notifier).setBiometricEnabled(_useBiometrics);

      // 3. Setup User Profile
      await ref.read(userProvider.notifier).register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      // main.dart will automatically route to MainNavigationScreen because userProvider is no longer null.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error during registration: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final clean = value.replaceAll(RegExp(r'\s+|-|\+'), '');
    
    // Accept standard 10 digit or international +233 (12 digits)
    String prefix = '';
    if (clean.length == 10 && clean.startsWith('0')) {
      prefix = clean.substring(0, 3);
    } else if (clean.length == 12 && clean.startsWith('233')) {
      prefix = '0${clean.substring(3, 5)}';
    } else {
      return 'Enter a valid Ghanaian mobile number';
    }

    const validPrefixes = ['024', '025', '053', '054', '055', '059', '020', '050', '026', '027', '056', '057'];
    if (!validPrefixes.contains(prefix)) {
      return 'Enter a valid Ghanaian mobile number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
          children: [
            _buildRegistrationForm(theme, isDark),
            _buildRecoveryCodeScreen(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(ThemeData theme, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.account_balance_wallet, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Welcome to BudgetBoss',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fully local. Fully secure. Let\'s set up your offline vault.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number (Ghana)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Create PIN (4-6 digits)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                validator: (v) => (v == null || v.length < 4) ? 'PIN must be 4-6 digits' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Confirm PIN', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_clock)),
                validator: (v) => v != _pinController.text ? 'PINs do not match' : null,
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Use Biometrics (Fingerprint/FaceID)'),
                subtitle: const Text('For faster access'),
                value: _useBiometrics,
                onChanged: (val) => setState(() => _useBiometrics = val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryCodeScreen(ThemeData theme, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.security, size: 64, color: Colors.amber[700]),
            const SizedBox(height: 16),
            Text(
              'Your Recovery Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Save this somewhere safe — you\'ll need it if you forget your PIN. We cannot recover it for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[300] : Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _recoveryCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _recoveryCode));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recovery code copied!')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            CheckboxListTile(
              title: const Text('I have saved my recovery code safely.'),
              value: _hasSavedCode,
              onChanged: (val) => setState(() => _hasSavedCode = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _hasSavedCode ? _completeRegistration : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Finish Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }
}
