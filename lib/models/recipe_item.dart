class RecipeItem {
  final String id;
  final String name;
  final String category;
  final List<String> ingredients;
  final String time;
  final String calories;
  final String steps;
  final String? imageUrl;

  const RecipeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.time,
    required this.calories,
    required this.steps,
    this.imageUrl,
  });

  RecipeItem copyWith({
    String? imageUrl,
  }) {
    return RecipeItem(
      id: id,
      name: name,
      category: category,
      ingredients: ingredients,
      time: time,
      calories: calories,
      steps: steps,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}