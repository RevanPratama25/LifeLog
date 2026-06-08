import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import all views for the bottom navigation
import '../../home/views/home_view.dart';
import '../../timeline/views/timeline_view.dart';
import '../../tasks/views/tasks_view.dart';
import '../../reflections/views/reflections_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BaseController extends GetxController {
  final currentIndex = 0.obs;
  
  // Observable for notifications
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('entries')
        .where('isTask', isEqualTo: true)
        .where('isDone', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      
      final now = DateTime.now();
      final List<Map<String, dynamic>> generatedNotifications = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final deadlineTimestamp = data['deadline'] as Timestamp?;
        final reminders = List<String>.from(data['reminders'] ?? []);
        final title = data['title']?.toString() ?? 'Task';
        
        if (deadlineTimestamp != null) {
          final deadline = deadlineTimestamp.toDate();
          
          for (String offset in reminders) {
            final reminderTime = _calculateReminderTime(deadline, offset);
            
            // If the reminder time has passed and it's within the last 24 hours
            if (reminderTime.isBefore(now) && now.difference(reminderTime).inHours < 24) {
              generatedNotifications.add({
                'id': '${doc.id}_$offset',
                'taskId': doc.id,
                'title': 'Reminder: $title',
                'time': reminderTime,
                'isRead': false, // In a full app, we'd store read state locally or in DB
              });
            }
          }
        }
      }

      // Sort by most recent first
      generatedNotifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
      
      notifications.value = generatedNotifications;
      unreadCount.value = generatedNotifications.where((n) => !(n['isRead'] as bool)).length;
    });
  }

  DateTime _calculateReminderTime(DateTime deadline, String offset) {
    switch (offset) {
      case 'at_deadline': return deadline;
      case '30_min': return deadline.subtract(const Duration(minutes: 30));
      case '1_hour': return deadline.subtract(const Duration(hours: 1));
      case '3_hours': return deadline.subtract(const Duration(hours: 3));
      case '5_hours': return deadline.subtract(const Duration(hours: 5));
      case '12_hours': return deadline.subtract(const Duration(hours: 12));
      case '1_day': return deadline.subtract(const Duration(days: 1));
      case '3_days': return deadline.subtract(const Duration(days: 3));
      case '7_days': return deadline.subtract(const Duration(days: 7));
      default: return deadline;
    }
  }

  void markAllAsRead() {
    final updated = notifications.map((n) {
      n['isRead'] = true;
      return n;
    }).toList();
    notifications.value = updated;
    unreadCount.value = 0;
  }

  // Pages displayed in the bottom navigation body
  final List<Widget> screens = [
    const HomeView(),
    const TaskView(),
    const ReflectionView(),
    const TimelineView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}