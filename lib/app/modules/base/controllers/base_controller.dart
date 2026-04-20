import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import semua view lu di sini
import '../../home/views/home_view.dart';
import '../../timeline/views/timeline_view.dart';
// Nanti import TaskView dan ReflectionsView kalau udah dibikin
import '../../tasks/views/tasks_view.dart';
import '../../reflections/views/reflections_view.dart';

class BaseController extends GetxController {
  final currentIndex = 0.obs;

  // Daftar halaman yang bakal diganti-ganti di dalam body
  final List<Widget> screens = [
    const HomeView(),
    const TaskView(),
    const TimelineView(),
    const ReflectionsView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}