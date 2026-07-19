import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/security_provider.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  String _errorMessage = '';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometrics();
    });
  }

  Future<void> _tryBiometrics() async {
    final securityNotifier = ref.read(securityProvider.notifier);
    final enabled = await securityNotifier.isBiometricEnabled();
    if (enabled) {
      await securityNotifier.authenticateWithBiometrics();
    }
  }

  void _onKeyPress(String value) {
    if (_pin.length < 6) {
      setState(() {
        _pin += value;
        _errorMessage = '';
      });
      // The old PIN allowed 4-6 digits, so we wait for enter unless we enforce a fixed length.
      // We'll let them type up to 6, and if they type 4 they can press 'OK' or we auto-submit if it's correct?
      // Since it's dynamic length, we need an 'OK' button.
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_pin.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits';
      });
      return;
    }

    setState(() {
      _isChecking = true;
    });

    final success = await ref.read(securityProvider.notifier).verifyPin(_pin);
    
    if (mounted && !success) {
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect PIN';
        _isChecking = false;
      });
    }
    // On success, securityProvider sets state to true, and main.dart's overlay will rebuild and remove PinScreen automatically.
  }

  void _onForgotPin() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPinDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Enter PIN',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock BudgetBoss',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              height: 24,
              child: Text(
                _errorMessage,
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            
            // Numpad
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRow(['1', '2', '3']),
                    _buildRow(['4', '5', '6']),
                    _buildRow(['7', '8', '9']),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          Icon(Icons.backspace, color: isDark ? Colors.white : Colors.black87),
                          _onDelete,
                        ),
                        _buildButton(
                          Text('0', style: GoogleFonts.outfit(fontSize: 28, color: isDark ? Colors.white : Colors.black87)),
                          () => _onKeyPress('0'),
                        ),
                        _buildButton(
                          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 32),
                          _verifyPin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            TextButton(
              onPressed: _onForgotPin,
              child: const Text('Forgot PIN?'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) {
        return _buildButton(
          Text(n, style: GoogleFonts.outfit(fontSize: 28, color: isDark ? Colors.white : Colors.black87)),
          () => _onKeyPress(n),
        );
      }).toList(),
    );
  }

  Widget _buildButton(Widget child, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class ForgotPinDialog extends ConsumerStatefulWidget {
  const ForgotPinDialog({super.key});

  @override
  ConsumerState<ForgotPinDialog> createState() => _ForgotPinDialogState();
}

class _ForgotPinDialogState extends ConsumerState<ForgotPinDialog> {
  final _recoveryController = TextEditingController();
  final _newPinController = TextEditingController();
  String _error = '';
  bool _verified = false;

  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return AlertDialog(
        title: const Text('Set New PIN'),
        content: TextField(
          controller: _newPinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'New 4-6 digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_newPinController.text.length >= 4) {
                ref.read(securityProvider.notifier).resetPin(_newPinController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save PIN'),
          )
        ],
      );
    }

    return AlertDialog(
      title: const Text('Recover PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter your recovery code to reset your PIN. Or use biometrics if enabled.'),
          const SizedBox(height: 16),
          TextField(
            controller: _recoveryController,
            decoration: const InputDecoration(labelText: 'Recovery Code (XXXX-XXXX-XXXX)'),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_error, style: const TextStyle(color: Colors.red)),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final valid = await ref.read(securityProvider.notifier).verifyRecoveryCode(_recoveryController.text);
            if (valid) {
              setState(() {
                _verified = true;
                _error = '';
              });
            } else {
              setState(() {
                _error = 'Invalid recovery code';
              });
            }
          },
          child: const Text('Verify'),
        ),
      ],
    );
  }
}
