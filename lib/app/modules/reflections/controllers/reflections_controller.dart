import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/firestore_helpers.dart';

class ReflectionController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for all entries, ordered by most recent first
  Stream<QuerySnapshot> get entriesStream =>
      userEntriesRef(_firestore, _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  /// Deletes an entry from Firestore.
  Future<void> deleteEntry(String docId) async {
    try {
      await userEntriesRef(_firestore, _auth.currentUser!.uid)
          .doc(docId)
          .delete();
          
      // Close bottom sheet if open
      if (Get.isBottomSheetOpen == true) {
        Get.back(); 
      }

      Get.snackbar('Deleted', 'Insight deleted successfully.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete data: $e');
    }
  }
}