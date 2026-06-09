import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'dart:io';
import '../utils/reminder_utils.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin and requests required permissions.
  Future<NotificationService> init() async {
    // Initialize timezone data
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 
    } catch (e) {
      debugPrint('Error setting local location, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    // Android icon setup
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS setup
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped! Payload: ${response.payload}');
      },
    );
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission
      await androidImplementation?.requestNotificationsPermission();

      // Request exact alarm permission
      await androidImplementation?.requestExactAlarmsPermission();
    }

    return this;
  }

  /// Schedules reminders with multiple offsets and optional alarm sound.
  Future<void> scheduleTaskReminders({
    required String docId,
    required String title,
    required String body,
    required DateTime deadline,
    required List<String> reminders,
    required bool enableAlarm,
    required String alarmSound,
  }) async {
    for (String offset in reminders) {
      DateTime scheduledTime = calculateReminderTime(deadline, offset);
      // Skip if the scheduled time has already passed
      if (scheduledTime.isBefore(DateTime.now())) continue;

      int notificationId = (docId + offset).hashCode;

      AndroidNotificationDetails androidDetails;
      if (enableAlarm) {
        androidDetails = AndroidNotificationDetails(
          'lifelog_alarm_channel_v3_$alarmSound',
          'Alarms ($alarmSound)',
          channelDescription: 'High priority alarms for task deadlines',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT (loops sound)
          sound: RawResourceAndroidNotificationSound(alarmSound),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          'lifelog_reminder_channel',
          'Reminders',
          channelDescription: 'Reminders for your activity deadlines',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        );
      }

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: docId,
      );
    }
  }


  /// Cancels all reminders associated with a given task document.
  Future<void> cancelTaskReminders(String docId) async {
    const List<String> possibleOffsets = [
      'at_deadline', '30_min', '1_hour', '3_hours', '5_hours',
      '12_hours', '1_day', '3_days', '7_days'
    ];
    
    for (String offset in possibleOffsets) {
      int id = (docId + offset).hashCode;
      await _notificationsPlugin.cancel(id: id);
    }
    
    // Also cancel legacy ID (docId.hashCode) for backward compatibility
    await _notificationsPlugin.cancel(id: docId.hashCode);
  }

  /// Returns all currently pending scheduled notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}