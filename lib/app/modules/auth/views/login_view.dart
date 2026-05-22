import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_pages.dart';

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
              Text(
                'Welcome Back.',
                style: Get.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue your productive journey.',
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 60),

              // Email field
              CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'YourEmail',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),

              // Password field
              Obx(
                () => CustomTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isObscure: controller.isPasswordHidden.value,
                  onTogglePassword: controller.togglePasswordVisibility,
                ),
              ),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Reset Password',
                      backgroundColor: AppColors.surface,
                      titleStyle: const TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.all(16),
                      content: Column(
                        children: [
                          const Text(
                            'Insert registered email to receive reset link.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller
                                .emailController, // Use existing email controller
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'YourEmail',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textConfirm: 'Send Link',
                      confirmTextColor: Colors.white,
                      onConfirm: () => controller.resetPassword(
                        controller.emailController.text,
                      ),
                      textCancel: 'Cancel',
                      cancelTextColor: AppColors.primary,
                      buttonColor: AppColors.primary,
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Login button with glow effect
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      elevation: 8,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Get.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      Routes.REGISTER,
                    ),
                    child: const Text(
                      'Register here',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
