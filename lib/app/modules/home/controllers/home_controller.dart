import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final userName = 'Revan'.obs;
  final streakDays = 5.obs;

  // Today's task list (placeholder data)
  final todayTasks = [
    {'title': 'Networking Lab', 'isDone': true},
    {'title': 'Review GetX Material', 'isDone': true},
    {'title': 'Firebase Integration', 'isDone': false},
    {'title': 'Update UI Dashboard', 'isDone': false},
  ].obs;

  // Recent reflections (placeholder data)
  final recentLogs = [
    {'title': 'More Focused Today', 'note': 'Finished tasks earlier without distractions.'},
    {'title': 'Need More Rest', 'note': 'Felt tired in the afternoon due to lack of sleep last night.'},
  ].obs;

  // Calculate task completion percentage
  double get taskProgress {
    if (todayTasks.isEmpty) return 0.0;
    int cleared = todayTasks.where((task) => task['isDone'] == true).length;
    return cleared / todayTasks.length;
  }

  // Formatted percentage text for the donut chart
  String get progressPercentage => "${(taskProgress * 100).toInt()}%";

  /// Signs out and navigates back to login.
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}