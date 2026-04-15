import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add item
  Future<void> addItem({
    required String title,
    required String description,
    required String type,
    required String location,
    required String imageUrl,
    required String userId,
  }) async {
    await _db.collection('items').add({
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get items
  Stream<QuerySnapshot> getItems() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}