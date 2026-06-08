import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/services/notification_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Get.putAsync(() => NotificationService().init());
  Get.put(AuthController(), permanent: true);

  runApp(
    GetMaterialApp(
      title: "LifeLog",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,

      // Apply theme
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always use dark mode to match design
    ),
  );
}
