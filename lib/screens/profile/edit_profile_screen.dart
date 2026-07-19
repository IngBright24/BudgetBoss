import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/storage_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        await ref.read(profilePictureProvider.notifier).setPicture(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final currentUser = StorageService.getUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        
        await StorageService.saveUser(updatedUser);
        ref.read(userProvider.notifier).refreshUser();
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Color(0xFF06B6D4),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profilePicPath = ref.watch(profilePictureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 2),
                      ),
                      child: ClipOval(
                        child: profilePicPath != null && File(profilePicPath).existsSync()
                            ? Image.file(
                                File(profilePicPath),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xFF020617) : Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                isDark: isDark,
                validator: (val) => val == null || val.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Phone cannot be empty' : null,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final fillColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444))),
      ),
    );
  }
}
