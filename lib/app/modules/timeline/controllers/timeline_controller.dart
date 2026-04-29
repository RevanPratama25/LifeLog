import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TimelineController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 Stream untuk dengerin data secara real-time
  // Kita urutkan berdasarkan 'createdAt' dari yang terbaru (descending: true)
  Stream<QuerySnapshot> get entriesStream => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('entries')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // Helper untuk format tanggal dari Timestamp Firebase ke String (Manual/Intl)
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    DateTime date = timestamp.toDate();
    // Bisa pakai intl DateFormat, tapi ini versi manual simpel:
    return "${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> completeTask(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(docId)
          .update({'isDone': true});
          
      Get.snackbar('Berhasil', 'Task diselesaikan dan masuk ke Log.',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal update status: $e',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 🔥 Fungsi Delete: Hapus dari Firestore
  Future<void> deleteEntry(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(docId)
          .delete();
          
      Get.snackbar('Terhapus', 'Data berhasil dihapus dari timeline.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}