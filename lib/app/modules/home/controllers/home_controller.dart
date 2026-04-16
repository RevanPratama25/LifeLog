import 'package:get/get.dart';

class HomeController extends GetxController {
  // Dummy data untuk UI
  final userName = 'Revan'.obs; 
  final streakDays = 5.obs;
  final totalLogsToday = 3.obs;
  final finishedToday = 3.obs;

  // List dummy untuk Task (Fokus Hari Ini)
  final todayTasks = [
    {'title': 'Praktikum Jaringan', 'isDone': false},
    {'title': 'Review Materi GetX', 'isDone': false},
  ].obs;

  // List dummy untuk Log (Refleksi Terbaru)
  final recentLogs = [
    {'title': 'Setup Firebase', 'note': 'Jangan lupa rules firestore di-update ke test mode.'},
    {'title': 'Bikin UI Design', 'note': 'Pilih warna ice frost blue.'},
  ].obs;
}