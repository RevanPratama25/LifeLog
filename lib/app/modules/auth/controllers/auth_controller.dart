import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Import Firebase Auth
import '../../../routes/app_pages.dart'; // Pastikan path ini benar untuk Routes.BASE

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  // 🔥 Inisialisasi instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void _showError(String message) {
    Get.snackbar(
      'Oops, Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // 🔥 Logic Validasi & Login Firebase
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password wajib diisi, ya.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Format email sepertinya tidak valid.');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    
    try {
      // 🔥 Nembak API Login Firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Kalau sukses, langsung pindah ke Navbar/Dashboard
      Get.offAllNamed(Routes.BASE); 
      
    } on FirebaseAuthException catch (e) {
      // 🔥 Menangkap error spesifik dari server Firebase
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        _showError('Email tidak terdaftar atau kredensial salah.');
      } else if (e.code == 'wrong-password') {
        _showError('Password yang kamu masukkan salah.');
      } else {
        _showError(e.message ?? 'Terjadi kesalahan tidak terduga.');
      }
    } catch (e) {
      _showError('Gagal koneksi ke server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 Logic Validasi & Register Firebase
  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Semua kolom wajib diisi untuk mendaftar.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Format email sepertinya tidak valid.');
      return;
    }

    if (password.length < 6) {
      _showError('Password minimal harus 6 karakter biar aman.');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    
    try {
      // 🔥 Nembak API Daftar Akun Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 Update display name di profil Firebase biar nama lengkapnya kesimpen
      await userCredential.user?.updateDisplayName(name);
      
      // Kalau sukses, langsung pindah ke Navbar/Dashboard
      Get.offAllNamed(Routes.BASE);
      
    } on FirebaseAuthException catch (e) {
      // 🔥 Menangkap error spesifik pendaftaran
      if (e.code == 'weak-password') {
        _showError('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        _showError('Email ini sudah digunakan akun lain.');
      } else {
        _showError(e.message ?? 'Gagal mendaftarkan akun.');
      }
    } catch (e) {
      _showError('Gagal koneksi ke server: $e');
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