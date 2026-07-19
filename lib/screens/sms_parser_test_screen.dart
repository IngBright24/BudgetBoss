import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../models/transaction.dart';

class SMSParserTestScreen extends StatefulWidget {
  const SMSParserTestScreen({super.key});

  @override
  State<SMSParserTestScreen> createState() => _SMSParserTestScreenState();
}

class _SMSParserTestScreenState extends State<SMSParserTestScreen> {
  List<BudgetTransaction> _transactions = [];
  bool _isLoading = false;

  Future<void> _scanSMS() async {
    setState(() => _isLoading = true);
    try {
      // Historical scan is removed. This button does nothing now.
      if (!mounted) return;
      setState(() {
        _transactions = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historical scan has been removed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Parser Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _scanSMS,
              child: const Text('Scan Financial SMS'),
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return ListTile(
                  title: Text('${tx.category}: GHS ${tx.amount}'),
                  subtitle: Text('To/From: ${tx.senderOrReceiver}\nID: ${tx.id}'),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
