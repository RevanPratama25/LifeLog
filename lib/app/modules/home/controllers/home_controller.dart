import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final userName = 'Revan'.obs; 
  final streakDays = 5.obs; // Contoh: 5 hari aktif

  // List Task hari ini
  final todayTasks = [
    {'title': 'Praktikum Jaringan', 'isDone': true},
    {'title': 'Review Materi GetX', 'isDone': true},
    {'title': 'Integrasi Firebase', 'isDone': false},
    {'title': 'Update UI Dashboard', 'isDone': false},
  ].obs;

  // List Refleksi terbaru
  final recentLogs = [
    {'title': 'Lebih Fokus Hari Ini', 'note': 'Bisa selesaikan task lebih awal tanpa distraksi.'},
    {'title': 'Perlu Istirahat', 'note': 'Terasa capek di siang hari karena kurang tidur semalam.'},
  ].obs;

  // Logic hitung persentase task yang beres
  double get taskProgress {
    if (todayTasks.isEmpty) return 0.0;
    int cleared = todayTasks.where((task) => task['isDone'] == true).length;
    return cleared / todayTasks.length;
  }

  // Helper buat teks di tengah donut
  String get progressPercentage => "${(taskProgress * 100).toInt()}%";
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login'); // Kembali ke halaman awal
  }
}