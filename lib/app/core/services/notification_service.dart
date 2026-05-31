import 'package:flutter/foundation.dart'; // Ditambahkan untuk debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    // 1. Inisialisasi Zona Waktu
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

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

    return this;
  }

  // 🔥 Fungsi untuk MENJADWALKAN pengingat
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Kalau waktunya udah lewat, nggak usah dijadwalin
    if (scheduledTime.isBefore(DateTime.now())) return;

    // FIX: zonedSchedule sekarang WAJIB pakai named parameters semua
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'lifelog_deadline_channel', 
          'Task Deadlines', 
          channelDescription: 'Pengingat untuk tenggat waktu aktivitasmu',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      payload: payload,
      // Parameter uiLocalNotificationDateInterpretation dihapus karena sudah usang
    );
  }

  // 🔥 Fungsi untuk MEMBATALKAN pengingat 
  Future<void> cancelReminder(int id) async {
    // FIX: cancel WAJIB pakai named parameter 'id'
    await _notificationsPlugin.cancel(id: id); 
  }
}