import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/firestore_helpers.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Category filter state
  final selectedCategory = 'ALL'.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Sorting state
  final isDescending = true.obs;

  // Text controller for completion notes when finishing a task
  final completionNoteController = TextEditingController();

  // Stream for active (incomplete) tasks
  Stream<QuerySnapshot> get activeTasksStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .where('isTask', isEqualTo: true)
          .where('isDone', isEqualTo: false)
          .orderBy('createdAt', descending: isDescending.value)
          .snapshots();

  // Stream for completed logs (isDone == true)
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
      
      // Prepare update payload
      Map<String, dynamic> updateData = {'isDone': true};

      // Only include the note if the user provided one
      if (note.isNotEmpty) {
        updateData['note'] = note;
      }

      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .update(updateData);
          
      // Clear form and close bottom sheet
      completionNoteController.clear();
      Get.back();

      Get.snackbar('Done!', 'Task completed and moved to Log.',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete task: $e');
    }
  }

  @override
  void onClose() {
    completionNoteController.dispose();
    super.onClose();
  }

  /// Deletes an entry from Firestore.
  Future<void> deleteTask(String docId) async {
    try {
      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .delete();
      Get.back();
      Get.snackbar('Deleted', 'Entry deleted successfully.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }
  
}