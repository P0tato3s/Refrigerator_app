import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FoodStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FoodStore({required this.uid});

  CollectionReference<Map<String, dynamic>> get _itemsRef =>
      _db.collection('users').doc(uid).collection('food_items');

  Stream<List<FoodItem>> watchItems() {
    return _itemsRef.orderBy('expiresOn').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItem.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addItem(FoodItem item) async {
    await _itemsRef.add(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _itemsRef.doc(id).delete();
  }

  Future<void> updateItem(FoodItem item) async {
    await _itemsRef.doc(item.id).update(item.toMap());
  }
}