import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State untuk filter kategori
  final selectedCategory = 'ALL'.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // State untuk sorting
  final isDescending = true.obs;

  // State untuk menyimpan catatan saat menyelesaikan Task
  final completionNoteController = TextEditingController();

  // 1. Stream untuk Task yang Aktif (Belum Selesai)
  Stream<QuerySnapshot> get activeTasksStream => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('entries')
      .where('isTask', isEqualTo: true)
      .where('isDone', isEqualTo: false)
      .orderBy('createdAt', descending: isDescending.value)
      .snapshots();

  // 2. Stream untuk Logs (Input Manual OR Task yang Selesai)
  // Note: Firestore tidak mendukung query OR yang kompleks lintas field dengan orderBy secara langsung, 
  // jadi kita tarik semua yang 'isDone: true' atau 'isTask: false' melalui logic filter atau query terpisah.
  // Untuk best practice sederhana, kita ambil yang sudah selesai/log manual di sini:
  Stream<QuerySnapshot> get logsStream => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('entries')
      .where('isDone', isEqualTo: true)
      .orderBy('createdAt', descending: isDescending.value)
      .snapshots();

  void toggleSort() => isDescending.toggle();

  // Fungsi untuk menandai task selesai (Update Firestore)
  Future<void> markAsDone(String docId) async {
    try {
      final note = completionNoteController.text.trim();
      
      // Siapkan data yang mau di-update
      Map<String, dynamic> updateData = {'isDone': true};
      
      // Kalau user ngisi insight-nya, kita masukin ke database. 
      // Kalau dikosongin, kita cuma update status isDone-nya aja.
      if (note.isNotEmpty) {
        updateData['note'] = note;
      }

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(docId)
          .update(updateData);
          
      // Bersihin form dan tutup bottom sheet
      completionNoteController.clear();
      Get.back(); // Untuk nutup Bottom Sheet
      
      Get.snackbar('Mantap!', 'Task diselesaikan dan masuk ke Log.',
          backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyelesaikan task: $e');
    }
  }

  @override
  void onClose() {
    completionNoteController.dispose();
    super.onClose();
  }

  //  Fungsi Delete 
  Future<void> deleteTask(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(docId)
          .delete();
      Get.back(); // Tutup Bottom Sheet kalau lagi kebuka
      Get.snackbar('Terhapus', 'Rencana berhasil dihapus.',
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus: $e');
    }
  }
  
}