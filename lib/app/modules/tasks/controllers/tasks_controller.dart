import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/firestore_helpers.dart';
import '../../../core/services/notification_service.dart';

class TaskController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Currently selected category filter for the list view.
  final selectedCategory = 'ALL'.obs;

  /// Search filter state.
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  /// Tab controller for switching between Active Tasks and Completed Logs.
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    completionNoteController.dispose();
    super.onClose();
  }

  /// Switches to the Completed Logs tab with animation.
  void switchToCompletedTab() {
    tabController.animateTo(1);
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  /// Sorting state: true = newest first, false = oldest first.
  final isDescending = true.obs;

  /// Text controller for the optional insight field when completing a task.
  final completionNoteController = TextEditingController();

  /// Stream for active (incomplete) tasks.
  Stream<QuerySnapshot> get activeTasksStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .where('isTask', isEqualTo: true)
          .where('isDone', isEqualTo: false)
          .orderBy('createdAt', descending: isDescending.value)
          .snapshots();

  /// Stream for completed logs (isDone == true).
  Stream<QuerySnapshot> get logsStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .where('isDone', isEqualTo: true)
          .orderBy('createdAt', descending: isDescending.value)
          .snapshots();

  void toggleSort() => isDescending.toggle();

  /// Marks a task as done, optionally saving a completion note.
  Future<void> markAsDone(String docId) async {
    try {
      final note = completionNoteController.text.trim();
      
      final Map<String, dynamic> updateData = {'isDone': true};

      if (note.isNotEmpty) {
        updateData['note'] = note;
      }

      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .update(updateData);
          
      await Get.find<NotificationService>().cancelTaskReminders(docId);

      completionNoteController.clear();
      Get.back();

      Get.snackbar('Done!', 'Task completed and moved to Log.',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete task: $e');
    }
  }

  /// Deletes an entry from Firestore.
  Future<void> deleteTask(String docId) async {
    try {
      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .delete();

      await Get.find<NotificationService>().cancelTaskReminders(docId);

      Get.back();
      Get.snackbar('Deleted', 'Entry deleted successfully.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }
}