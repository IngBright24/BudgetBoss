import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/sqlite_helper.dart';

class LocalBackupService {
  
  /// Exports the SQLite database file via the system Share sheet.
  static Future<void> exportBackup(BuildContext context) async {
    try {
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'budget_boss.db');
      
      final file = File(dbPath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data to backup yet.')));
        }
        return;
      }
      
      // Share the file
      final xFile = XFile(file.path, mimeType: 'application/octet-stream');
      final result = await Share.shareXFiles([xFile], text: 'Budget Boss Backup (${DateTime.now().toIso8601String().split('T').first})');
      
      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup exported successfully.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  /// Restores the SQLite database from a user-selected file.
  static Future<void> importBackup(BuildContext context) async {
    try {
      // Pick the backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return; // User canceled
      }

      final backupFilePath = result.files.single.path;
      if (backupFilePath == null) {
        throw Exception('Failed to get file path.');
      }

      // Read the imported file
      final backupFile = File(backupFilePath);
      
      // Get the current database path
      final dbFolder = await getDatabasesPath();
      final targetDbPath = join(dbFolder, 'budget_boss.db');
      final targetFile = File(targetDbPath);

      // Overwrite the existing DB file
      // We must close the existing connection if it's open, but sqflite doesn't expose a global close easily.
      // Copying over it usually works on mobile, but to be safe we can delete and copy.
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await backupFile.copy(targetDbPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Backup restored! Please restart the app to see all your data.'),
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }
}
