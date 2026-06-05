import 'package:flutter/foundation.dart'; // Ditambahkan untuk debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'dart:io';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    // 1. Inisialisasi Zona Waktu
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 
    } catch (e) {
      debugPrint('Error setting local location, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    // 2. Setup Ikon Android 
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Setup iOS 
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // 4. Mulai Plugin (FIX: Pakai named parameter 'settings')
    await _notificationsPlugin.initialize(
      settings: initSettings, 
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // FIX: Pakai debugPrint untuk menghindari warning avoid_print
        debugPrint('Notifikasi diklik! Payload: ${response.payload}'); 
      },
    );
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Minta izin untuk memunculkan notifikasi
      await androidImplementation?.requestNotificationsPermission();
      
      // Minta izin untuk menjadwalkan alarm yang tepat
      await androidImplementation?.requestExactAlarmsPermission();
    }

    return this;
  }

  // 🔥 Fungsi untuk MENJADWALKAN pengingat dengan banyak offset dan opsi alarm
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
      DateTime scheduledTime = _calculateReminderTime(deadline, offset);
      // Kalau waktunya udah lewat, nggak usah dijadwalin
      if (scheduledTime.isBefore(DateTime.now())) continue;

      int notificationId = (docId + offset).hashCode;

      AndroidNotificationDetails androidDetails;
      if (enableAlarm) {
        androidDetails = AndroidNotificationDetails(
          'lifelog_alarm_channel_v3_$alarmSound', // Dynamic channel ID to bypass Android channel caching per sound
          'Alarms ($alarmSound)',
          channelDescription: 'High priority alarms for task deadlines',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT (loops sound)
          sound: RawResourceAndroidNotificationSound(alarmSound), // Dynamic sound file name (no extension)
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm, // Specify this is an alarm sound
          category: AndroidNotificationCategory.alarm, // Specify the category as alarm
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          'lifelog_reminder_channel',
          'Reminders',
          channelDescription: 'Pengingat untuk tenggat waktu aktivitasmu',
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

  // 🔥 Fungsi untuk MEMBATALKAN semua pengingat terkait satu tugas
  Future<void> cancelTaskReminders(String docId) async {
    const List<String> possibleOffsets = [
      'at_deadline', '30_min', '1_hour', '3_hours', '5_hours',
      '12_hours', '1_day', '3_days', '7_days'
    ];
    
    for (String offset in possibleOffsets) {
      int id = (docId + offset).hashCode;
      await _notificationsPlugin.cancel(id: id);
    }
    
    // Juga cancel ID legacy (docId.hashCode) in case ada notifikasi lama sebelum refactor
    await _notificationsPlugin.cancel(id: docId.hashCode);
  }

  // Fetch semua notifikasi yang sedang aktif
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}