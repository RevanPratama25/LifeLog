import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void _showError(String message) {
    Get.snackbar(
      'Oops, Something went wrong',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Validates credentials and signs in via Firebase.
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
    
    try {
      // Authenticate with Firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // On success, navigate to the main dashboard
      Get.offAllNamed(Routes.BASE);
      
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific auth errors
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        _showError('Email not registered or invalid credentials.');
      } else if (e.code == 'wrong-password') {
        _showError('Incorrect password.');
      } else {
        _showError(e.message ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      _showError('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates input and creates a new Firebase account.
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
    
    try {
      // Create Firebase account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the display name to Firebase profile
      await userCredential.user?.updateDisplayName(name);

      // On success, navigate to the main dashboard
      Get.offAllNamed(Routes.BASE);
      
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific registration errors
      if (e.code == 'weak-password') {
        _showError('Password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showError('Email is already in use.');
      } else {
        _showError(e.message ?? 'Failed to register account.');
      }
    } catch (e) {
      _showError('Failed to connect to server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends a password reset email.
  void resetPassword(String emailInput) async {
    final email = emailInput.trim();
    
    if (email.isEmpty) {
      _showError('Insert your email to reset password.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Invalid email format.');
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.back(); // Close the email input dialog
      
      Get.snackbar(
        'Email Sent',
        'Please check your inbox or spam folder.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send reset email.');
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}