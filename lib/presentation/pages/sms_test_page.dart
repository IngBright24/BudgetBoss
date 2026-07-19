import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/sms_provider.dart';
import '../../data/parser/sms_parser.dart';

class SmsTestPage extends ConsumerStatefulWidget {
  const SmsTestPage({super.key});

  @override
  ConsumerState<SmsTestPage> createState() => _SmsTestPageState();
}

class _SmsTestPageState extends ConsumerState<SmsTestPage> {
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _senderController = TextEditingController(text: 'MTN Mobile Money');
  
  Map<String, dynamic>? _parsedResult;

  void _testParse() {
    final result = SmsParser.parse(_smsController.text, _senderController.text, DateTime.now());
    setState(() {
      _parsedResult = result?.toMap();
    });
  }

  void _saveTestSms() {
    if (_smsController.text.isEmpty) return;
    ref.read(smsProvider.notifier).addManualTestSms(_smsController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test SMS Processed and Wallet Updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer: SMS Parser Test'),
        backgroundColor: const Color(0xFF06B6D4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender Name/Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Raw SMS Content',
                hintText: 'e.g. You have received GHS 250.00 from John Doe...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testParse,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4)),
                    child: const Text('Test Parse', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTestSms,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    child: const Text('Save & Update Wallet', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_parsedResult != null) ...[
              const Text('Parsed Output:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _parsedResult!.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Text('${e.value}')),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
