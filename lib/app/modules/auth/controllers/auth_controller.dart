import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../routes/app_pages.dart'; // Pastikan path ini benar untuk Routes.BASE

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  // Inisialisasi instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void _showError(String message) {
    Get.snackbar(
      'Oops, Something went wrong',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // Logic Validasi & Login Firebase
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
      // Nembak API Login Firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Kalau sukses, langsung pindah ke Navbar/Dashboard
      Get.offAllNamed(Routes.BASE); 
      
    } on FirebaseAuthException catch (e) {
      // Menangkap error spesifik dari server Firebase
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

  // Logic Validasi & Register Firebase
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
      // Nembak API Daftar Akun Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name di profil Firebase biar nama lengkapnya kesimpen
      await userCredential.user?.updateDisplayName(name);
      
      // Kalau sukses, langsung pindah ke Navbar/Dashboard
      Get.offAllNamed(Routes.BASE);
      
    } on FirebaseAuthException catch (e) {
      // Menangkap error spesifik pendaftaran
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

  // Fungsi Reset Password
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
      Get.back(); // Tutup dialog input email
      
      Get.snackbar(
        'Email Sent',
        'Please check your inbox or spam folder.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Gagal mengirim email reset.');
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
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