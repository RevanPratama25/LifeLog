import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// A reusable styled text field used across Auth and AddEntry forms.
///
/// Provides consistent styling with [AppColors], optional password toggle,
/// prefix icon, and configurable max lines / keyboard type.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? onTogglePassword;
  final int maxLines;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.isPassword = false,
    this.isObscure = false,
    this.onTogglePassword,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.primary)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
