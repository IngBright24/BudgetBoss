import 'dart:io';

void main() {
  final file = File('lib/data/parser/regex_patterns.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('BudgetTransaction ID', 'Transaction ID');
  file.writeAsStringSync(content);
}
