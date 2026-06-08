import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? overrideImageUrl;

  const ProfileAvatar({
    super.key,
    this.radius = 18,
    this.overrideImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AuthController authController = Get.find<AuthController>();
      final user = authController.currentUser.value;
      
      String? photoUrl = overrideImageUrl;
      if (photoUrl == null || photoUrl.isEmpty) {
        photoUrl = user?.photoURL;
      }
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        if (photoUrl.startsWith('file://')) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(File(photoUrl.replaceFirst('file://', ''))),
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            onBackgroundImageError: (exception, stackTrace) {},
          );
        } else if (photoUrl.startsWith('http')) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(photoUrl),
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            onBackgroundImageError: (exception, stackTrace) {},
          );
        } else {
          // If it's a direct file path without file://
          return CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(File(photoUrl)),
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            onBackgroundImageError: (exception, stackTrace) {},
          );
        }
      }

      // Default Placeholder
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Icon(
          Icons.person,
          color: AppColors.primary.withValues(alpha: 0.8),
          size: radius * 1.2,
        ),
      );
    });
  }
}
