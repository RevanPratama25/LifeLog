import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/firestore_helpers.dart';

class TimelineController extends GetxController {
  // Search query state
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

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

  // Real-time stream of all entries, ordered by most recent first
  Stream<QuerySnapshot> get entriesStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();


  /// Marks a task as done, optionally saving a completion note.
  Future<void> completeTask(String docId) async {
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
