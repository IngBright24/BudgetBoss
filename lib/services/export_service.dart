import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  static Future<void> exportTransactionsToCSV(List<BudgetTransaction> transactions, String currencyCode) async {
    String csv = 'ID,Date,Category,Type,Amount ($currencyCode),Recipient/Sender,Message\n';
    
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    
    for (var tx in transactions) {
      csv += '${tx.id},${formatter.format(tx.timestamp)},"${tx.category}",${tx.type.name},${tx.amount},"${tx.senderOrReceiver}","${tx.rawMessage.replaceAll('\n', ' ')}"\n';
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/budget_boss_history.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'My BudgetBoss Activity History');
  }

  static Future<void> exportTransactionsToPDF(List<BudgetTransaction> transactions, String currencyCode) async {
    final pdf = pw.Document();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('BudgetBoss BudgetTransaction History')),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Type', 'Amount ($currencyCode)', 'Details'],
            data: transactions.map((tx) => [
              formatter.format(tx.timestamp),
              tx.category,
              tx.type.name.toUpperCase(),
              tx.amount.toStringAsFixed(2),
              tx.senderOrReceiver,
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'budget_boss_history.pdf');
  }
}
