import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns the 'entries' subcollection reference for the given user.
///
/// This centralizes the Firestore path construction that is repeated
/// across multiple controllers (AddEntry, Tasks, Timeline, Reflections).
CollectionReference<Map<String, dynamic>> userEntriesRef(
  FirebaseFirestore firestore,
  String uid,
) {
  return firestore.collection('users').doc(uid).collection('entries');
}
