import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Jangan lupa import ini
import 'package:intl/date_symbol_data_local.dart'; // Dan ini

class HomeController extends GetxController {
  // 1. Siapkan variabel kosong dulu
  final userName = ''.obs; 
  final streakDays = 5.obs; //5 hari  aktif
  final currentDate = ''.obs; // Pindahin deklarasi variabel ke atas biar rapi

  // 2. Tambahkan instance FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // 3. Ambil nama user pas controller pertama kali dibuat
    _loadUserData();
    _formatCurrentDate();
  }

  void _loadUserData() {
    // Ambil displayName yang sudah kamu simpan pas Register tadi
    // Kalau namanya kosong, kasih cadangan tulisan "User"
    userName.value = _auth.currentUser?.displayName ?? "User";
  }

  void _formatCurrentDate() {
    initializeDateFormatting('id_ID', null);
    DateTime now = DateTime.now();
    var formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    currentDate.value = formatter.format(now);
  }

  // ... (sisa kodingan todayTasks dan recentLogs tetap sama)

  

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