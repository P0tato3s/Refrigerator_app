import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime expiresOn;
  final String? photoUrl;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiresOn,
    this.photoUrl,
  });

  int daysUntilExpiry(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return exp.difference(today).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiresOn': Timestamp.fromDate(expiresOn),
      'photoUrl': photoUrl,
    };
  }

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 0) as int,
      unit: map['unit'] ?? '',
      expiresOn: (map['expiresOn'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'] as String?,
    );
  }
}