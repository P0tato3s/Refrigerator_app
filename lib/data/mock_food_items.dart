import '../models/food_item.dart';

final mockFoodItems = <FoodItem>[
  FoodItem(
    id: "1",
    name: "Milk",
    category: "Dairy",
    quantity: 1,
    unit: "carton",
    expiresOn: DateTime.now().add(const Duration(days: 2)),
  ),
  FoodItem(
    id: "2",
    name: "Eggs",
    category: "Dairy",
    quantity: 12,
    unit: "pcs",
    expiresOn: DateTime.now().add(const Duration(days: 10)),
  ),
  FoodItem(
    id: "3",
    name: "Spinach",
    category: "Produce",
    quantity: 1,
    unit: "bag",
    expiresOn: DateTime.now().subtract(const Duration(days: 1)),
  ),
  FoodItem(
    id: "4",
    name: "Chicken Breast",
    category: "Meat",
    quantity: 2,
    unit: "lbs",
    expiresOn: DateTime.now().add(const Duration(days: 4)),
  ),
  FoodItem(
    id: "5",
    name: "Strawberries",
    category: "Produce",
    quantity: 1,
    unit: "box",
    expiresOn: DateTime.now().add(const Duration(days: 1)),
  ),
];