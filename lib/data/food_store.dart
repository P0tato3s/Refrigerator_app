import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FoodStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FoodItem>> watchItems() {
    return _db.collection('food_items')
        .orderBy('expiresOn')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItem.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addItem(FoodItem item) async {
    await _db.collection('food_items').add(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _db.collection('food_items').doc(id).delete();
  }

  Future<void> updateItem(FoodItem item) async {
    await _db.collection('food_items').doc(item.id).update(item.toMap());
  }
}