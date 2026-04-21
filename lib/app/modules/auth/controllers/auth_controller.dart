import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // 🔥 Helper fungsi biar gampang nampilin error
  void _showError(String message) {
    Get.snackbar(
      'Please Wait...',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // 🔥 Logic Validasi Login
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email and password must be filled');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Invalid Email Format');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    
    // Simulasi delay
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    Get.offAllNamed('/base');
  }

  // Logic Validasi Register
  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('All fields must be filled');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Invalid Email Format');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    
    // Simulasi delay
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    Get.offAllNamed('/base');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}