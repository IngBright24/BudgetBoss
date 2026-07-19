import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final profilePictureProvider = StateNotifierProvider<ProfilePictureNotifier, String?>((ref) {
  return ProfilePictureNotifier();
});

class ProfilePictureNotifier extends StateNotifier<String?> {
  ProfilePictureNotifier() : super(_load());

  static String? _load() {
    return StorageService.settingsBox.get('profile_picture_path') as String?;
  }

  Future<void> setPicture(String path) async {
    await StorageService.settingsBox.put('profile_picture_path', path);
    state = path;
  }

  Future<void> clearPicture() async {
    await StorageService.settingsBox.delete('profile_picture_path');
    state = null;
  }
}
