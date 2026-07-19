import 'dart:io';

void main() {
  final libDir = Directory('test');
  
  for (var file in libDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      final smartRegex = RegExp(r'\bTransaction\b(?!(Type|Repository|Notifier|s|Model))');
      
      if (smartRegex.hasMatch(content)) {
        content = content.replaceAll(smartRegex, 'BudgetTransaction');
        file.writeAsStringSync(content);
        print('Renamed in: ${file.path}');
      }
    }
  }
}
