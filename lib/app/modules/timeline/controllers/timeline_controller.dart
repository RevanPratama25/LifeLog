import 'package:get/get.dart';

class TimelineController extends GetxController {
  // Dummy data Activity Logs yang sudah selesai
  final historyLogs = [
    {
      'title': 'Selesai Setup Firebase',
      'category': 'Project',
      'date': '16 April 2026 • 14:30',
      'note': 'Aturan security rules diubah ke test mode sementara.',
    },
    {
      'title': 'Mengerjakan UI Add Entry',
      'category': 'Coding',
      'date': '16 April 2026 • 10:15',
      'note': 'Logic form validation dan anti-double tap udah aman.',
    },
    {
      'title': 'Meeting Kelompok',
      'category': 'Kuliah',
      'date': '15 April 2026 • 19:00',
      'note': 'Bagi tugas untuk presentasi MVP minggu depan.',
    },
    {
      'title': 'Push Kode ke GitHub',
      'category': 'Project',
      'date': '15 April 2026 • 17:45',
      'note': '', // Sengaja dikosongin untuk test UI
    },
    {
      'title': 'Review Materi GetX',
      'category': 'Belajar',
      'date': '14 April 2026 • 20:00',
      'note': 'Konsep Binding dan Lazy Loading cukup paham.',
    },
  ].obs;
}