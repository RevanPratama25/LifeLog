import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/root_controller.dart';
import '../../../core/theme/app_colors.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.bubble_chart, color: AppColors.primary, size: 80),
            ),
            const SizedBox(height: 32),
            Text(
              'LIFELOG',
              style: Get.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}