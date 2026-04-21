import 'package:get/get.dart';

class TaskController extends GetxController {
  final currentTab = 'Active'.obs; // Active atau Completed
  
  // Dummy Data sesuai desain
  final activeTasks = [
    {
      'title': 'Review quarterly growth report',
      'time': '09:30 AM',
      'category': 'DEEP FOCUS',
      'hasNote': false,
      'isHighPriority': false,
    },
    {
      'title': 'Daily synchronization with creative team',
      'time': '11:00 AM',
      'category': 'PRODUCT',
      'hasNote': false,
      'isHighPriority': true, // Bikin teks merah "High Priority"
    },
    {
      'title': 'Synthesize project reflections',
      'time': '02:15 PM',
      'category': 'LIFE',
      'hasNote': true,
      'noteText': '"Focus on the emotional shift during the client presentation."',
      'isHighPriority': false,
    },
    {
      'title': 'Order ergonomic workstation kit',
      'time': '04:00 PM',
      'category': 'PERSONAL',
      'hasNote': false,
      'isHighPriority': false,
    },
  ].obs;

  void changeTab(String tab) {
    currentTab.value = tab;
  }
}