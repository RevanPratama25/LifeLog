import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/firestore_helpers.dart';
import '../../../core/services/notification_service.dart';

class TimelineController extends GetxController {
  /// Search query state.
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  /// Category & sort state.
  final selectedCategory = 'ALL'.obs;
  final isDescending = true.obs;

  void toggleSort() => isDescending.toggle();
  void setCategory(String category) => selectedCategory.value = category;

  @override
  void onInit() {
    super.onInit();
    // Update the search state whenever the user types
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    completionNoteController.dispose();
    super.onClose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final completionNoteController = TextEditingController();

  /// Real-time stream of all entries, ordered by creation date.
  Stream<QuerySnapshot> get entriesStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .orderBy('createdAt', descending: isDescending.value)
          .snapshots();


  /// Marks a task as done, optionally saving a completion note.
  Future<void> completeTask(String docId) async {
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

      Get.snackbar(
        'Done!',
        'Task completed and moved to Log.',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Deletes an entry from Firestore.
  Future<void> deleteEntry(String docId) async {
    try {
      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .delete();

      await Get.find<NotificationService>().cancelTaskReminders(docId);

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Deleted',
        'Data successfully deleted.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete data: $e',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
