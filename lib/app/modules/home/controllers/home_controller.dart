import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/utils/firestore_helpers.dart';
import '../../base/controllers/base_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Daily momentum: how many activities completed today.
  final todayMomentum = 0.obs;
  final targetMomentum = 3; // Default target: 3 activities per day

  /// Streak tracking.
  final currentStreak = 0.obs;
  final bestStreak = 0.obs;

  /// Counts displayed in the quick stats cards.
  final activeTasksCount = 0.obs;
  final totalLogsCount = 0.obs;

  /// Active dates for streak visualization (format: YYYY-MM-DD).
  final activeDatesList = <String>[].obs;

  /// Data lists for the dashboard sections.
  final upcomingDeadlines = <QueryDocumentSnapshot>[].obs;
  final recentInsights = <QueryDocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToStats();
  }

  /// Listens to real-time changes in the user's entries collection
  /// and derives all dashboard statistics from a single stream.
  void _listenToStats() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    userEntriesRef(_firestore, uid).snapshots().listen((snapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final hPlus7 = today.add(
        const Duration(days: 7, hours: 23, minutes: 59, seconds: 59),
      );

      int activeCount = 0;
      int logsCount = 0;
      int todayMomentumCount = 0;

      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      List<QueryDocumentSnapshot> tempUpcoming = [];
      List<QueryDocumentSnapshot> tempInsights = [];

      // Set of dates where the user completed an activity
      Set<String> activeDates = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isTask = data['isTask'] == true;
        final isDone = data['isDone'] == true;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final deadline = (data['deadline'] as Timestamp?)?.toDate();
        final note = data['note']?.toString().trim() ?? '';

        // Record completed activity dates (YYYY-MM-DD format)
        if (isDone && createdAt != null) {
          final dateString =
              "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
          activeDates.add(dateString);

          // If completed today, increment momentum
          if (dateString == todayStr) {
            todayMomentumCount++;
          }
        }

        // 1. Count stats
        if (isTask && !isDone) activeCount++;
        if (isDone && createdAt != null && createdAt.isAfter(thirtyDaysAgo)) {
          logsCount++;
        }

        // 2. Filter upcoming deadlines (next 7 days)
        if (isTask && !isDone && deadline != null) {
          if (deadline.isAfter(today.subtract(const Duration(seconds: 1))) &&
              deadline.isBefore(hPlus7)) {
            tempUpcoming.add(doc);
          }
        }

        // 3. Filter entries with insights
        if (note.isNotEmpty) {
          tempInsights.add(doc);
        }
      }

      // Current streak: count backwards from today (or yesterday if no activity today)
      int streak = 0;
      DateTime checkDate = today;

      // Tolerance: if no activity today, check from yesterday
      if (!activeDates.contains(todayStr)) {
        checkDate = today.subtract(const Duration(days: 1));
      }

      while (true) {
        final dateStr =
            "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
        if (activeDates.contains(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      currentStreak.value = streak;

      // Best streak: find the longest consecutive date sequence
      int maxStreak = 0;
      int tempStreak = 0;
      DateTime? prevDate;

      final sortedDates = activeDates.toList()..sort();
      for (var dateStr in sortedDates) {
        final parts = dateStr.split('-');
        final d = DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

        if (prevDate == null) {
          tempStreak = 1;
        } else {
          final diff = d.difference(prevDate).inDays;
          if (diff == 1) {
            tempStreak++;
          } else if (diff > 1) {
            tempStreak = 1;
          }
        }
        if (tempStreak > maxStreak) {
          maxStreak = tempStreak;
        }
        prevDate = d;
      }
      bestStreak.value = maxStreak;

      // Sort upcoming deadlines by deadline date (ascending)
      tempUpcoming.sort(
        (a, b) =>
            ((a.data() as Map<String, dynamic>)['deadline'] as Timestamp)
                .toDate()
                .compareTo(
                  ((b.data() as Map<String, dynamic>)['deadline'] as Timestamp)
                      .toDate(),
                ),
      );
      // Sort insights by creation date (newest first)
      tempInsights.sort(
        (a, b) =>
            (((b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)
                        ?.toDate() ??
                    DateTime(1970))
                .compareTo(
              ((a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)
                      ?.toDate() ??
                  DateTime(1970),
            ),
      );

      activeTasksCount.value = activeCount;
      totalLogsCount.value = logsCount;
      todayMomentum.value = todayMomentumCount;
      activeDatesList.assignAll(sortedDates);
      upcomingDeadlines.assignAll(tempUpcoming.take(5).toList());
      recentInsights.assignAll(tempInsights.take(5).toList());
    });
  }

  /// Navigates to a specific bottom navigation tab.
  void navigateToTab(int index) {
    Get.find<BaseController>().changePage(index);
  }

  /// Navigates to Tasks tab → Completed Logs sub-tab.
  void navigateToCompletedLogs() {
    Get.find<BaseController>().changePage(1);

    if (Get.isRegistered<TaskController>()) {
      Get.find<TaskController>().switchToCompletedTab();
    }
  }

  /// Deletes an entry from Firestore using the centralized helper.
  ///
  /// Replaces direct `FirebaseFirestore.instance.collection('entries')` calls
  /// that were previously in the view layer.
  Future<void> deleteEntry(String docId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await userEntriesRef(_firestore, uid).doc(docId).delete();
      await Get.find<NotificationService>().cancelTaskReminders(docId);

      Get.snackbar(
        'Deleted',
        'Entry deleted successfully.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  /// Shows a bottom sheet listing all pending notification reminders.
  Future<void> showPendingNotifications() async {
    final notificationService = Get.find<NotificationService>();
    final pendingRequests = await notificationService.getPendingNotifications();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pending Reminders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (pendingRequests.isEmpty)
              const Text(
                'No pending reminders.',
                style: TextStyle(color: Colors.white54),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final req = pendingRequests[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.notifications_active,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        req.title ?? 'Reminder',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        req.body ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
