import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import all views for the bottom navigation
import '../../home/views/home_view.dart';
import '../../timeline/views/timeline_view.dart';
import '../../tasks/views/tasks_view.dart';
import '../../reflections/views/reflections_view.dart';

class BaseController extends GetxController {
  final currentIndex = 0.obs;

  // Pages displayed in the bottom navigation body
  final List<Widget> screens = [
    const HomeView(),
    const TaskView(),
    const ReflectionView(),
    const TimelineView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}