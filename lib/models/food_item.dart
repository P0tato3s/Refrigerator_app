class FoodItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime expiresOn;
  final String? photoPath;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiresOn,
    this.photoPath,
  });

  int daysUntilExpiry(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return exp.difference(today).inDays;
  }
}