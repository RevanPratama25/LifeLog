import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/utils/firestore_helpers.dart';
import '../../base/controllers/base_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabel untuk Daily Momentum
  final todayMomentum = 0.obs;
  final targetMomentum = 3; // Target default: 3 aktivitas per hari

  //Variabel Streak & Week Completion
  final currentStreak = 0.obs;
  final weekCompletion = List.filled(7, false).obs;

  // Rx variables untuk menampung hitungan
  final activeTasksCount = 0.obs;
  final totalLogsCount = 0.obs;

  // Rx variables baru untuk nampung data list
  final upcomingDeadlines = <QueryDocumentSnapshot>[].obs;
  final recentInsights = <QueryDocumentSnapshot>[].obs;


  @override
  void onInit() {
    super.onInit();
    _listenToStats();
  }

  // Fungsi untuk memantau perubahan data secara real-time
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

      //Set untuk nyimpen tanggal-tanggal di mana user aktif (ada isDone == true)
      Set<String> activeDates = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isTask = data['isTask'] == true;
        final isDone = data['isDone'] == true;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final deadline = (data['deadline'] as Timestamp?)?.toDate();
        final note = data['note']?.toString().trim() ?? '';

        // Catat tanggal aktivitas selesai (ubah format ke YYYY-MM-DD biar gampang dicocokin)
        if (isDone && createdAt != null) {
          final dateString = "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
          activeDates.add(dateString);
          
          // Kalau tanggal selesainya adalah HARI INI, tambah poin momentum!
          if (dateString == todayStr) {
            todayMomentumCount++;
          }
        }

        // 1. Hitung Stats
        if (isTask && !isDone) activeCount++;
        if (isDone && createdAt != null && createdAt.isAfter(thirtyDaysAgo))
          logsCount++;

        // 2. Filter Upcoming Deadlines
        if (isTask && !isDone && deadline != null) {
          if (deadline.isAfter(today.subtract(const Duration(seconds: 1))) &&
              deadline.isBefore(hPlus7)) {
            tempUpcoming.add(doc);
          }
        }

        // 3. Filter Recent Insights
        if (note.isNotEmpty) {
          tempInsights.add(doc);
        }
      }

      // LOGIKA MINGGU INI (Senin - Minggu)
      // weekday: 1 = Senin, 7 = Minggu
      final currentWeekday = now.weekday;
      final startOfWeek = today.subtract(Duration(days: currentWeekday - 1));

      List<bool> tempWeekCompletion = List.filled(7, false);
      for (int i = 0; i < 7; i++) {
        final dayToCheck = startOfWeek.add(Duration(days: i));
        final dateString =
            "${dayToCheck.year}-${dayToCheck.month.toString().padLeft(2, '0')}-${dayToCheck.day.toString().padLeft(2, '0')}";

        // Kalau tanggal itu ada di activeDates, berarti true
        if (activeDates.contains(dateString)) {
          tempWeekCompletion[i] = true;
        }
      }
      weekCompletion.assignAll(tempWeekCompletion);

      //LOGIKA TOTAL STREAK (Hitung mundur dari hari ini atau kemarin)
      int streak = 0;
      DateTime checkDate = today;

      // Kasih toleransi: kalau hari ini belum ngisi, cek dari kemarin
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
          break; // Putus streak-nya
        }
      }
      currentStreak.value = streak;

      // Sorting (sama kayak sebelumnya)
      tempUpcoming.sort(
        (a, b) => ((a.data() as Map<String, dynamic>)['deadline'] as Timestamp)
            .toDate()
            .compareTo(
              ((b.data() as Map<String, dynamic>)['deadline'] as Timestamp)
                  .toDate(),
            ),
      );
      tempInsights.sort(
        (a, b) =>
            (((b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)
                        ?.toDate() ??
                    DateTime(1970))
                .compareTo(
                  ((a.data() as Map<String, dynamic>)['createdAt']
                              as Timestamp?)
                          ?.toDate() ??
                      DateTime(1970),
                ),
      );

      activeTasksCount.value = activeCount;
      totalLogsCount.value = logsCount;
      todayMomentum.value = todayMomentumCount;
      upcomingDeadlines.assignAll(tempUpcoming.take(5).toList());
      recentInsights.assignAll(tempInsights.take(5).toList());
    });
  }

  // Fungsi navigasi antar tab via BaseController
  void navigateToTab(int index) {
    Get.find<BaseController>().changePage(index);
  }

  // Fungsi navigasi ke Tasks -> Completed Logs
  void navigateToCompletedLogs() {
    // 1. Pindah tab utama ke Tasks (asumsi index 1)
    Get.find<BaseController>().changePage(1);

    // 2. Beritahu TasksController untuk pindah ke sub-tab "Completed Logs"
    // Pastikan TasksController udah ada di memori
    if (Get.isRegistered<TaskController>()) {
      Get.find<TaskController>().switchToCompletedTab();
    }
  }
}
