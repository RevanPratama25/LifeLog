import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final profileImageUrl = ''.obs;
  final localImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _auth.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      profileImageUrl.value = user.photoURL ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        localImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removePhoto() async {
    localImagePath.value = '';
    profileImageUrl.value = '';
  }

  Future<void> saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar('Invalid', 'Name cannot be empty',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      String? finalPhotoUrl = profileImageUrl.value;

      // If there's a new local image picked, save its local file path
      if (localImagePath.value.isNotEmpty) {
        final File file = File(localImagePath.value);
        finalPhotoUrl = 'file://${file.path}';

      } else if (profileImageUrl.value.isEmpty) {
        // User removed the photo
        finalPhotoUrl = null;
      }

      // Update Auth Profile
      await user.updateDisplayName(newName);
      if (finalPhotoUrl == null) {
        // Cannot pass null to updatePhotoURL in current Firebase version, usually empty string is fine
        // Wait, updatePhotoURL accepts String? in the latest version. Let's try it.
        await user.updatePhotoURL(null);
      } else {
        await user.updatePhotoURL(finalPhotoUrl);
      }

      // Wait for auth state to propagate and update UI
      await user.reload();
      
      // Notify AuthController to update globally
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().currentUser.value = _auth.currentUser;
      }

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
