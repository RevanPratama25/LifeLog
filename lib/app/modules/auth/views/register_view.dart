import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Header
              Text('Create Account.', style: Get.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Start your productive journey with LifeLog today.', 
                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
              
              const SizedBox(height: 40),

              // Name field
              CustomTextField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              
              // Email field
              CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'example@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              
              // Password field
              Obx(() => CustomTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: 'Create a strong password',
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: controller.isPasswordHidden.value,
                onTogglePassword: controller.togglePasswordVisibility,
              )),
              
              const SizedBox(height: 40),
              
              // Register button with glow effect
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 8,
                  ),
                  onPressed: controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Register Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )),
              ),
              
              const SizedBox(height: 40),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: Get.textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Log in here',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}