import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class RootController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    // Delay a bit for splash screen effect (optional)
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    // Checking user status
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // If token is still valid, go to Navbar/Home
      Get.offAllNamed(Routes.BASE);
    } else {
      // If not logged in or token expired, go to Login page
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}