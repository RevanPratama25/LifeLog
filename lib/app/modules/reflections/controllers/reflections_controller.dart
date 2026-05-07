import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReflectionController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk narik semua data (urut dari terbaru)
  Stream<QuerySnapshot> get entriesStream => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('entries')
      .orderBy('createdAt', descending: true)
      .snapshots();

      // 🔥 Fungsi Hapus Data
  Future<void> deleteEntry(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(docId)
          .delete();
          
      // Tutup bottom sheet kalau lagi kebuka
      if (Get.isBottomSheetOpen == true) {
        Get.back(); 
      }
      
      Get.snackbar('Terhapus', 'Insight berhasil dihapus.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e');
    }
  }
}