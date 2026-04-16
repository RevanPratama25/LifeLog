import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart'; // Import file theme yang baru dibuat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      title: "LifeLog",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      
      // TERAPIN TEMA
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Paksa selalu dark mode sesuai vibe
    ),
  );
}