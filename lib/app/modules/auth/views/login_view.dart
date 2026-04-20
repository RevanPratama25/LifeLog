import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Header
              Text('Welcome Back.', style: Get.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Log in untuk melanjutkan perjalanan produktifmu.', 
                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
              
              const SizedBox(height: 60),
              
              // Form Email
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'contoh@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              
              // Form Password
              Obx(() => _buildTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: 'Masukkan password',
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: controller.isPasswordHidden.value,
                onTogglePassword: controller.togglePasswordVisibility,
              )),
              
              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // Nanti untuk fitur reset password
                  child: const Text('Lupa Password?', style: TextStyle(color: AppColors.primary)),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Login Button dengan Glow
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: AppColors.primary.withOpacity(0.5),
                    elevation: 8, // Efek Glow
                  ),
                  onPressed: controller.isLoading.value ? null : controller.login,
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              ),
              
              const SizedBox(height: 40),
              
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: Get.textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Get.toNamed('/register'), // Ganti dengan Routes.REGISTER
                    child: const Text(
                      'Daftar di sini',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField Widget (Biar kodenya bersih)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Get.textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}